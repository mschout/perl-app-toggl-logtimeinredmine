package App::Toggl::LogToRedmine;

# ABSTRACT: Log Time Entries from Toggl in Redmine

use Modern::Perl;

use MooseX::App::Simple qw(ConfigXDG);
use Carp::Assert::More qw(assert_like);
use DateTime::Format::ISO8601;
use DateTime;
use Function::Parameters;
use Time::HiRes qw(usleep);
use Types::URI -all;
use WWW::Mechanize;
use WebService::Toggl;
use IO::Socket::SSL;

option api_key => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
    documentation => 'Your Toggl API Key',
    cmd_flag      => 'api-key'
);

option workspace => (
    is            => 'ro',
    isa           => 'Int',
    required      => 1,
    documentation => 'The Toggle Workspace Id that contains your time entries'
);

option client => (
    is            => 'ro',
    isa           => 'Int',
    required      => 1,
    documentation => 'The Toggle Client Id for the client that contains your time entries'
);

option redmine_url => (
    is            => 'ro',
    isa           => Uri,
    coerce        => 1,
    required      => 1,
    documentation => 'The base URL for your redmine instance',
    cmd_flag      => 'redmine-url'
);

option redmine_username => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
    documentation => 'Your redmine username',
    cmd_flag      => 'redmine-username'
);

option redmine_password => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
    documentation => 'Your redmine password',
    cmd_flag      => 'redmine-password'
);

option dry_run => (
    is            => 'ro',
    isa           => 'Bool',
    default       => 0,
    documentation => 'Do not actually log anything to redmine',
    cmd_flag      => 'dry-run'
);

parameter date => (
    is            => 'ro',
    isa           => 'Str',
    required      => 1,
    documentation => 'The date for the time entries to copy in YYYY-MM-DD format'
);

has _mech => (
    is      => 'ro',
    isa     => 'WWW::Mechanize',
    lazy    => 1,
    default => sub { WWW::Mechanize->new }
);

has _toggl => (
    is      => 'ro',
    isa     => 'WebService::Toggl',
    lazy    => 1,
    default => method() { WebService::Toggl->new({ api_key => $self->api_key }) }
);

has _datetime_since => (
    is => 'ro',
    isa => 'DateTime',
    lazy => 1,
    default => method() {
        DateTime::Format::ISO8601->parse_datetime($self->date);
    }
);

has _datetime_until => (
    is      => 'ro',
    isa     => 'DateTime',
    lazy    => 1,
    default => method() {
        $self->_datetime_since->clone->add(days => 1)->subtract(seconds => 1);
    }
);

has _summary_report => (
    is      => 'ro',
    isa     => 'WebService::Toggl::Report::Summary',
    lazy    => 1,
    default => method() {
        $self->_toggl->summary({
            workspace_id => $self->workspace,
            client       => $self->client,
            grouping     => 'projects',
            subgrouping  => 'time_entries',
            since        => $self->_datetime_since,
            until        => $self->_datetime_until
        });
    }
);

around BUILDARGS => fun ($orig, $self, %args) {
    my $default_config = "$ENV{HOME}/.config/toggl-log-to-redmine/config.yaml";

    if (not defined $args{config} and -f $default_config) {
        $args{config} = $default_config;
    }

    $self->$orig(%args);
};

method run() {
    unless ($self->_summary_report->data->@*) {
        say 'No time entries for ' . $self->_datetime_since->ymd('-');
        exit;
    }

    $self->_login_to_redmine;

    say 'Time Entries for ' . $self->_datetime_since->ymd('-');
    say '';

    for my $project ($self->_summary_report->data->@*) {
        # skip time entries for projects that are not related to a redmine ticket
        my $ticket = $project->{title}{project} or next;
        next unless $ticket =~ /^(?<ticket>[0-9]+) /;

        say $ticket;
        say $self->_redmine_url_for_path('/issues/').$+{ticket};
        say '-' x 80;

        for my $item ($project->{items}->@*) {
            my $hours = miliseconds_to_hours($item->{time});
            my $comment = $item->{title}{time_entry} or next;  # skip entries without a comment

            say "$hours $comment";

            $self->_log_time(ticket => $+{ticket}, hours => $hours, comment => $comment);
            usleep(250);
        }
    }
}

method _redmine_url_for_path ($path) {
    my $url = $self->redmine_url->clone;

    $url->path($path);

    $url->as_string;
}

method _login_to_redmine() {
    my $mech = $self->_mech;

    $mech->get($self->_redmine_url_for_path('/login'));
    $mech->form_number(1);
    $mech->set_fields(
        username => $self->redmine_username,
        password => $self->redmine_password
    );
    $mech->click;
}


method _log_time (:$ticket, :$hours, :$comment) {
    return if $self->dry_run;

    my $mech = $self->_mech;

    $mech->get( $self->_redmine_url_for_path('/projects/inforuptcy-client/time_entries/new') );

    assert_like($mech->content, qr/new_time_entry/);

    $mech->form_number(2);
    $mech->set_fields(
        'time_entry[issue_id]'    => $ticket,
        'time_entry[hours]'       => $hours,
        'time_entry[comments]'    => $comment,
        'time_entry[spent_on]'    => $self->_datetime_since->ymd('-'),
        'time_entry[activity_id]' => 9
    );
    $mech->click;

    if ($mech->content =~ /Issue is invalid/) {
        warn "Issue number is invalid - time not logged\n";
        return;
    }

    assert_like($mech->content, qr/Successful creation/i);
}

fun miliseconds_to_hours ($mili_seconds) {
    sprintf '%0.02f', $mili_seconds / 1000 / 3600;
}

__PACKAGE__->meta->make_immutable;
