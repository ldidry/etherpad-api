package Etherpad::API;
use strict;
use LWP::UserAgent;
use URI::Escape;
use JSON::XS;
use Carp qw(carp);


BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.10';
    @ISA         = qw(Exporter);
    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}

#################### main pod documentation begin ###################


=head1 NAME

Etherpad::API - Access Etherpad Lite API easily

=head1 SYNOPSIS

  use Etherpad::API;
  my $ec = Etherpad::API->new({
    url      => "http://pad.example.com",
    apikey   => "teirnausetsraunieti",
    user     => "apiuser",
    password => "apipassword"
  });

  $ec->create_pad('new_pad_name');

=head1 DESCRIPTION

This is a client for the Etherpad Lite HTTP API.

=head1 USAGE

=cut

#################### main pod documentation end ###################




#################### subroutine header begin ####################

=head2 new

 Usage     : my $ec = Etherpad::API->new({ url => "http://pad.example.com", apikey => "secretapikey" });
 Purpose   : Constructor
 Returns   : An Etherpad::API object
 Argument  : An mandatory hash reference, containing at least two keys:
                url      : mandatory, the epl URL (trailing slashes will be removed)
                apikey   : mandatory, the epl API key
                user     : optional, the user for epl authentication
                password : optional, the passowrd for epl authentication

=cut

#################### subroutine header end ####################

sub new {
    my ($class, $parameters) = @_;
    return undef unless (defined($parameters->{url}) && defined($parameters->{apikey}));

    $parameters->{url} =~ s#/+$## if (defined($parameters->{url}));
    if (defined($parameters->{user}) && defined($parameters->{password})) {
        $parameters->{url} =~ s#^(https?://)#$1$parameters->{user}:$parameters->{password}@#;
    }

    $parameters->{ua} = LWP::UserAgent->new;

    my $self = bless ($parameters, ref ($class) || $class);
    return $self;
}


#################### subroutine header begin ####################

=head2 apikey

 Usage     : $ec->apikey();
 Purpose   : Get the apikey
 Returns   : The apikey

=cut

#################### subroutine header end ####################

sub apikey {
    my $self = shift;
    return $self->{apikey};
}


#################### subroutine header begin ####################

=head2 url

 Usage     : $ec->url();
 Purpose   : Get the epl URL
 Returns   : The epl URL

=cut

#################### subroutine header end ####################

sub url {
    my $self = shift;
    return $self->{url};
}


#################################################################
=head2 Groups

Pads can belong to a group. The padID of grouppads is starting with a groupID like g.asdfasdfasdfasdf$test

=cut
#################################################################

#################### subroutine header begin ####################

=head3 create_group

 Usage     : $ec->create_group();
 Purpose   : Creates a new group
 Returns   : The new group ID

=cut

#################### subroutine header end ####################

sub create_group {
    my $self = shift;

    my $api    = 1;
    my $method = 'createGroup';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{groupID};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 create_group_if_not_exists_for

 Usage     : $ec->create_group_if_not_exists_for('myGroupId');
 Purpose   : This functions helps you to map your application group ids to epl group ids
 Returns   : The epl group id
 Argument  : Your application group id

=cut

#################### subroutine header end ####################


sub create_group_if_not_exists_for {
    my $self        = shift;
    my $my_group_id = shift;

    carp 'Please provide a group id' unless (defined($my_group_id));

    my $api    = 1;
    my $method = 'createGroupIfNotExistsFor';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&myGroupId=' . $my_group_id;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{groupID};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 delete_group

 Usage     : $ec->delete_group('groupId');
 Purpose   : Deletes a group
 Returns   : 1 if it succeeds
 Argument  : The id of the group you want to delete

=cut

#################### subroutine header end ####################


sub delete_group {
    my $self     = shift;
    my $group_id = shift;

    carp 'Please provide a group id' unless (defined($group_id));

    my $api    = 1;
    my $method = 'deleteGroup';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&groupID=' . $group_id;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return 1;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 list_pads

 Usage     : $ec->list_pads('groupId');
 Purpose   : Returns all pads of this group
 Returns   : An array or an array reference (depending on the context) which contains the pad ids
 Argument  : The id of the group from which you want the pads

=cut

#################### subroutine header end ####################


sub list_pads {
    my $self     = shift;
    my $group_id = shift;

    carp 'Please provide a group id' unless (defined($group_id));

    my $api    = 1;
    my $method = 'listPads';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&groupID=' . $group_id;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return (wantarray) ? @{$hash->{data}->{padIDs}}: $hash->{data}->{padIDs};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 create_group_pad

 Usage     : $ec->create_group_pad('groupID', 'padName' [, 'text'])
 Purpose   : Creates a new pad in this group
 Returns   : 1 if it succeeds
 Argument  : The group id, the pad name, optionally takes the pad's initial text

=cut

#################### subroutine header end ####################


sub create_group_pad {
    my $self     = shift;
    my $group_id = shift;
    my $pad_name = shift;
    my $text     = shift;

    carp 'Please provide at least 2 arguments : the group id and the pad name' unless (defined($pad_name));

    my $api    = 1;
    my $method = 'createGroupPad';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&groupID=' . $group_id . '&padName=' . $pad_name;
       $request .= '&text=' . uri_escape($text) if (defined($text));
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return 1;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 list_all_groups

 Usage     : $ec->list_all_groups()
 Purpose   : Lists all existing groups
 Returns   : An array or an array reference (depending on the context) which contains the groups ids

=cut

#################### subroutine header end ####################


sub list_all_groups {
    my $self = shift;

    my $api    = 1.1;
    my $method = 'listAllGroups';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return (wantarray) ? @{$hash->{data}->{groupIDs}}: $hash->{data}->{groupIDs};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################################################################
=head2 Author

These authors are bound to the attributes the users choose (color and name).

=cut
#################################################################

#################### subroutine header begin ####################

=head3 create_author

 Usage     : $ec->create_author(['name'])
 Purpose   : Creates a new author
 Returns   : The new author ID
 Argument  : Optionally takes a string as argument : the new author's name

=cut

#################### subroutine header end ####################


sub create_author {
    my $self = shift;
    my $name = shift;

    my $api    = 1;
    my $method = 'createAuthor';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&name=' . $name if (defined($name));
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{authorID};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 create_author_if_not_exists_for

 Usage     : $ec->create_author_if_not_exists_for(authorMapper [, name])
 Purpose   : This functions helps you to map your application author ids to epl author ids
 Returns   : The epl author ID
 Argument  : Your application author ID (mandatory) and optionally the epl author name

=cut

#################### subroutine header end ####################


sub create_author_if_not_exists_for {
    my $self          = shift;
    my $author_mapper = shift;
    my $name          = shift;

    carp 'Please provide your application author id' unless (defined($author_mapper));

    my $api    = 1;
    my $method = 'createAuthorIfNotExistsFor';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&authorMapper=' . $author_mapper;
       $request .= '&name=' . $name if (defined($name));
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{authorID};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 list_pads_of_author

 Usage     : $ec->list_pads_of_author('authorID')
 Purpose   : Returns an array of all pads this author contributed to
 Returns   : An array or an array reference depending on the context, containing the pads names
 Argument  : An epl author ID

=cut

#################### subroutine header end ####################


sub list_pads_of_author {
    my $self      = shift;
    my $author_id = shift;

    carp 'Please provide an author id' unless (defined($author_id));

    my $api    = 1;
    my $method = 'listPadsOfAuthor';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&authorID=' . $author_id;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return (wantarray) ? @{$hash->{data}->{padIDs}}: $hash->{data}->{padIDs};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 get_author_name

 Usage     : $ec->get_author_name('authorID')
 Purpose   : Returns the Author Name of the author
 Returns   : The author name
 Argument  : The epl author ID

=cut

#################### subroutine header end ####################


sub get_author_name {
    my $self      = shift;
    my $author_id = shift;

    carp 'Please provide an author id' unless (defined($author_id));

    my $api    = 1.1;
    my $method = 'getAuthorName';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&authorID=' . $author_id;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            # Change in the API, without documentation
            my $data = (ref($hash->{data}) eq 'HASH') ? $hash->{data}->{authorName} : $hash->{data};
            return $data;
        } else {
            carp $hash->{message};
        }
    } else {
        carp $response->status_line;
    }
}


#################################################################
=head2 Session

Sessions can be created between a group and an author. This allows an author to access more than one group. The sessionID will be set as a cookie to the client and is valid until a certain date. The session cookie can also contain multiple comma-seperated sessionIDs, allowing a user to edit pads in different groups at the same time. Only users with a valid session for this group, can access group pads. You can create a session after you authenticated the user at your web application, to give them access to the pads. You should save the sessionID of this session and delete it after the user logged out.

=cut
#################################################################

#################### subroutine header begin ####################

=head3 create_session

 Usage     : $ec->create_session('groupID', 'authorID', 'validUntil')
 Purpose   : Creates a new session. validUntil is an unix timestamp in seconds
 Returns   : The epl session ID
 Argument  : An epl group ID, an epl author ID and an valid unix timestamp (the session validity end date)

=cut

#################### subroutine header end ####################


sub create_session {
    my $self        = shift;
    my $group_id    = shift;
    my $author_id   = shift;
    my $valid_until = shift;

    carp 'Please provide 3 arguments : the group id, the author id and a valid unix timestamp' unless (defined($valid_until));
    carp 'Please provide a *valid* unix timestamp as third argument' unless ($valid_until =~ m/\d+/);

    my $api    = 1;
    my $method = 'createSession';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&groupID=' . $group_id . '&authorID=' . $author_id . '&validUntil=' . $valid_until;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{sessionID};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 delete_session

 Usage     : $ec->delete_session('sessionID')
 Purpose   : Deletes a session
 Returns   : 1 if it succeeds
 Argument  : An epl session ID

=cut

#################### subroutine header end ####################


sub delete_session {
    my $self       = shift;
    my $session_id = shift;

    carp 'Please provide a session id' unless (defined($session_id));

    my $api    = 1;
    my $method = 'deleteSession';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&sessionID=' . $session_id;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return 1;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 get_session_info

 Usage     : $ec->get_session_info('sessionID')
 Purpose   : Returns informations about a session
 Returns   : An hash reference, containing 3 keys : authorID, groupID and validUntil
 Argument  : An epl session ID

=cut

#################### subroutine header end ####################


sub get_session_info {
    my $self       = shift;
    my $session_id = shift;

    carp 'Please provide a session id' unless (defined($session_id));

    my $api    = 1;
    my $method = 'getSessionInfo';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&sessionID=' . $session_id;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 list_sessions_of_group

 Usage     : $ec->list_sessions_of_group('groupID')
 Purpose   : Returns all sessions of a group
 Returns   : Returns a hash reference, which keys are sessions ID and values are sessions infos (see get_session_info)
 Argument  : An epl group ID

=cut

#################### subroutine header end ####################


sub list_sessions_of_group {
    my $self     = shift;
    my $group_id = shift;

    carp 'Please provide a group id' unless (defined($group_id));

    my $api    = 1;
    my $method = 'listSessionsOfGroup';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&groupID=' . $group_id;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 list_sessions_of_author

 Usage     : $ec->list_sessions_of_author('authorID')
 Purpose   : Returns all sessions of an author
 Returns   : Returns a hash reference, which keys are sessions ID and values are sessions infos (see get_session_info)
 Argument  : An epl group ID

=cut

#################### subroutine header end ####################


sub list_sessions_of_author {
    my $self      = shift;
    my $author_id = shift;

    carp 'Please provide an author id' unless (defined($author_id));

    my $api    = 1;
    my $method = 'listSessionsOfAuthor';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&authorID=' . $author_id;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################################################################
=head2 Pad Content

Pad content can be updated and retrieved through the API.

=cut
#################################################################

#################### subroutine header begin ####################

=head3 get_text

 Usage     : $ec->get_text('padID', ['rev'])
 Purpose   : Returns the text of a pad
 Returns   : A string, containing the text of the pad
 Argument  : Takes a pad ID (mandatory) and optionally a revision number

=cut

#################### subroutine header end ####################


sub get_text {
    my $self   = shift;
    my $pad_id = shift;
    my $rev    = shift;

    carp 'Please provide at least a pad id' unless (defined($pad_id));

    my $api    = 1;
    my $method = 'getText';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
       $request .= '&rev=' . $rev if (defined($rev));
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{text};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 set_text

 Usage     : $ec->set_text('padID', 'text')
 Purpose   : Sets the text of a pad
 Returns   : 1 if it succeeds
 Argument  : Takes a pad ID and the text you want to set (both mandatory)

=cut

#################### subroutine header end ####################


sub set_text {
    my $self   = shift;
    my $pad_id = shift;
    my $text   = shift;

    carp 'Please provide 2 arguments : a pad id and a text' unless (defined($text));

    my $api    = 1;
    my $method = 'setText';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id) . '&text=' . uri_escape($text);
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return 1;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 get_html

 Usage     : $ec->get_html('padID', ['rev'])
 Purpose   : Returns the text of a pad formatted as html
 Returns   : A string, containing the text of the pad formatted as html
 Argument  : Takes a pad ID (mandatory) and optionally a revision number

=cut

#################### subroutine header end ####################


sub get_html {
    my $self   = shift;
    my $pad_id = shift;
    my $rev    = shift;

    carp 'Please provide at least a pad id' unless (defined($pad_id));

    my $api    = 1;
    my $method = 'getHTML';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
       $request .= '&rev=' . $rev if (defined($rev));
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{html};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################################################################
=head2 Chat

=cut
#################################################################

#################### subroutine header begin ####################

=head3 get_chat_history

 Usage     : $ec->get_chat_history('padID' [, start, end])
 Purpose   : Returns
              - a part of the chat history, when start and end are given
              - the whole chat history, when no extra parameters are given
 Returns   : An array or an array reference, depending of the context, containing hash references with 4 keys :
              - text     => text of the message
              - userId   => epl user id
              - time     => unix timestamp of the message
              - userName => epl user name
 Argument  : Takes a pad ID (mandatory) and optionally the start and the end numbers of the messages you want.
             The start number can't be higher than or equal to the current chatHead. The first chat message is number 0.
             If you specify a start but not an end, all messages will be returned.

=cut

#################### subroutine header end ####################


sub get_chat_history {
    my $self   = shift;
    my $pad_id = shift;
    my $start  = shift;
    my $end    = shift;

    carp 'Please provide at least a pad id' unless (defined($pad_id));

    my $api    = '1.2.7';
    my $method = 'getChatHistory';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . $pad_id;
       $request .= '&start=' . $start if (defined($start));
       $request .= '&end='   . $end   if (defined($end));
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return (wantarray) ? @{$hash->{data}->{messages}}: $hash->{data}->{messages};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 get_chat_head

 Usage     : $ec->get_chat_head('padID')
 Purpose   : Returns the chatHead (last number of the last chat-message) of the pad
 Returns   : The last chat-message number. -1 if there is no chat message
 Argument  : A pad ID

=cut

#################### subroutine header end ####################


sub get_chat_head {
    my $self   = shift;
    my $pad_id = shift;

    carp 'Please provide a pad id' unless (defined($pad_id));

    my $api    = '1.2.7';
    my $method = 'getChatHead';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . $pad_id;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{chatHead};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################################################################
=head2 Pad

Group pads are normal pads, but with the name schema GROUPID$PADNAME. A security manager controls access of them and its forbidden for normal pads to include a $ in the name.

=cut
#################################################################

#################### subroutine header begin ####################

=head3 create_pad

 Usage     : $ec->create_pad('padID' [, 'text'])
 Purpose   : Creates a new (non-group) pad. Note that if you need to create a group Pad, you should call create_group_pad.
 Returns   : 1 if it succeeds
 Argument  : Takes a pad ID (mandatory) and optionally a text to fill the pad

=cut

#################### subroutine header end ####################


sub create_pad {
    my $self   = shift;
    my $pad_id = shift;
    my $text   = shift;

    carp 'Please provide at least a pad id' unless (defined($pad_id));

    my $api    = 1;
    my $method = 'createPad';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
       $request .= '&text=' . uri_escape($text) if (defined($text));
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return 1;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 get_revisions_count

 Usage     : $ec->get_revisions_count('padID')
 Purpose   : Returns the number of revisions of this pad
 Returns   : The number of revisions
 Argument  : A pad ID

=cut

#################### subroutine header end ####################


sub get_revisions_count {
    my $self   = shift;
    my $pad_id = shift;

    carp 'Please provide a pad id' unless (defined($pad_id));

    my $api    = 1;
    my $method = 'getRevisionsCount';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{revisions};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 get_users_count

 Usage     : $ec->get_users_count('padID')
 Purpose   : Returns the number of user that are currently editing this pad
 Returns   : The number of users
 Argument  : A pad ID

=cut

#################### subroutine header end ####################


sub get_users_count {
    my $self   = shift;
    my $pad_id = shift;

    carp 'Please provide a pad id' unless (defined($pad_id));

    my $api = 1;
    my $method = 'padUsersCount';
    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{padUsersCount};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 pad_users

 Usage     : $ec->pad_users('padID')
 Purpose   : Returns the list of users that are currently editing this pad
 Returns   : An array or an array reference, depending of the context, containing hash references with 3 keys : colorId, name and timestamp
 Argument  : A pad ID

=cut

#################### subroutine header end ####################


sub pad_users {
    my $self   = shift;
    my $pad_id = shift;

    carp 'Please provide a pad id' unless (defined($pad_id));

    my $api    = 1.1;
    my $method = 'padUsers';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return (wantarray) ? @{$hash->{data}->{padUsers}} : $hash->{data}->{padUsers};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 delete_pad

 Usage     : $ec->delete_pad('padID')
 Purpose   : Deletes a pad
 Returns   : 1 if it succeeds
 Argument  : A pad ID

=cut

#################### subroutine header end ####################


sub delete_pad {
    my $self   = shift;
    my $pad_id = shift;

    carp 'Please provide a pad id' unless (defined($pad_id));

    my $api    = 1;
    my $method = 'deletePad';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return 1;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 get_read_only_id

 Usage     : $ec->get_read_only_id('padID')
 Purpose   : Returns the read only link of a pad
 Returns   : A string
 Argument  : A pad ID

=cut

#################### subroutine header end ####################


sub get_read_only_id {
    my $self   = shift;
    my $pad_id = shift;

    carp 'Please provide a pad id' unless (defined($pad_id));

    my $api    = 1;
    my $method = 'getReadOnlyID';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{readOnlyID};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 set_public_status

 Usage     : $ec->set_public_status('padID', 'publicStatus')
 Purpose   : Sets a boolean for the public status of a pad
 Returns   : 1 if it succeeds
 Argument  : A pad ID and the public status you want to set : 1 or 0

=cut

#################### subroutine header end ####################


sub set_public_status {
    my $self          = shift;
    my $pad_id        = shift;
    my $public_status = shift;

    carp 'Please provide 2 arguments : a pad id and a public status (1 or 0)' unless (defined($public_status));

    $public_status = ($public_status) ? JSON::XS::true : JSON::XS::false;

    my $api    = 1;
    my $method = 'setPublicStatus';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id) . '&publicStatus=' . $public_status;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return 1;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 get_public_status

 Usage     : $ec->get_public_status('padID')
 Purpose   : Return true of false
 Returns   : 1 or 0
 Argument  : A pad ID

=cut

#################### subroutine header end ####################


sub get_public_status {
    my $self   = shift;
    my $pad_id = shift;

    carp 'Please provide a pad id' unless (defined($pad_id));

    my $api    = 1;
    my $method = 'getPublicStatus';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return ($hash->{data}->{publicStatus}) ? 1 : 0;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 set_password

 Usage     : $ec->set_password('padID', 'password')
 Purpose   : Returns ok or a error message
 Returns   : 1 if it succeeds
 Argument  : A pad ID and a password

=cut

#################### subroutine header end ####################


sub set_password {
    my $self     = shift;
    my $pad_id   = shift;
    my $password = shift;

    carp 'Please provide 2 arguments : a pad id and a password' unless (defined($password));

    my $api    = 1;
    my $method = 'setPassword';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id) . '&password=' . uri_escape($password);
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return 1;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 is_password_protected

 Usage     : $ec->is_password_protected('padID')
 Purpose   : Returns true or false
 Returns   : 1 or 0
 Argument  : A pad ID

=cut

#################### subroutine header end ####################


sub is_password_protected {
    my $self   = shift;
    my $pad_id = shift;

    carp 'Please provide a pad id' unless (defined($pad_id));

    my $api    = 1;
    my $method = 'isPasswordProtected';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return ($hash->{data}->{passwordProtection}) ? 1 : 0;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 list_authors_of_pad

 Usage     : $ec->list_authors_of_pad('padID')
 Purpose   : Returns an array of authors who contributed to this pad
 Returns   : An array or an array reference depending on the context, containing the epl authors IDs
 Argument  : A pad ID

=cut

#################### subroutine header end ####################


sub list_authors_of_pad {
    my $self   = shift;
    my $pad_id = shift;

    carp 'Please provide a pad id' unless (defined($pad_id));

    my $api    = 1;
    my $method = 'listAuthorsOfPad';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return (wantarray) ? @{$hash->{data}->{authorIDs}} : $hash->{data}->{authorIDs};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 list_names_of_authors_of_pad

 Usage     : $ec->list_names_authors_of_pad('padID')
 Returns   : Returns an array of the names of the authors who contributed to this pad in list context
             Returns an array reference in scalar context
 Argument  : The pad name

=cut

#################### subroutine header end ####################


sub list_names_of_authors_of_pad {
    my $self   = shift;
    my $pad_id = shift;

    carp 'Please provide a pad id' unless (defined($pad_id));

    my @names;
    my $anonymous = 0;

    my @authors = $self->list_authors_of_pad($pad_id);
    for my $author (@authors) {
        my $name = $self->get_author_name($author);
        if (defined($name)) {
            push @names, $name;
        } else {
            $anonymous++;
        }
    }
    @names = sort(@names);
    push @names, $anonymous . ' anonymous' if ($anonymous);

    return (wantarray) ? @names : \@names;
}


#################### subroutine header begin ####################

=head3 get_last_edited

 Usage     : $ec->get_last_edited('padID')
 Purpose   : Returns the timestamp of the last revision of the pad
 Returns   : A unix timestamp
 Argument  : A pad ID

=cut

#################### subroutine header end ####################


sub get_last_edited {
    my $self   = shift;
    my $pad_id = shift;

    carp 'Please provide at least a pad id' unless (defined($pad_id));

    my $api    = 1;
    my $method = 'getLastEdited';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
       $request .= '&padID=' . uri_escape($pad_id);
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return $hash->{data}->{lastEdited};
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head3 send_clients_message

 Usage     : $ec->send_clients_message('padID', 'msg')
 Purpose   : Sends a custom message of type msg to the pad
 Returns   : 1 if it succeeds
 Argument  : A pad ID and the message you want to send

=cut

#################### subroutine header end ####################


sub send_clients_message {
    my $self   = shift;
    my $pad_id = shift;
    my $msg    = shift;

    carp "Please provide 2 arguments : the pad id and a message" unless (defined($msg));

    my $api    = 1.1;
    my $method = 'sendAPIsMessage';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
    $request .= '&padID=' . uri_escape($pad_id) . 'msg=' . $msg;
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return 1;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### subroutine header begin ####################

=head2 check_token

 Usage     : $ec->check_token()
 Purpose   : Returns ok when the current api token is valid
 Returns   : 1 if the token is valid, 0 otherwise

=cut

#################### subroutine header end ####################


sub check_token {
    my $self = shift;

    my $api    = 1.2;
    my $method = 'checkToken';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            return 1;
        } else {
            return 0;
        }
    }
    else {
        carp $response->status_line;
    }
}


#################################################################
=head2 Pads
=cut
#################################################################

#################### subroutine header begin ####################

=head3 list_all_pads

 Usage     : $ec->list_all_pads()
 Purpose   : Lists all pads on this epl instance
 Returns   : An array or an array reference depending on the context, containing the pads names

=cut

#################### subroutine header end ####################


sub list_all_pads {
    my $self = shift;

    my $api    = '1.2.1';
    my $method = 'listAllPads';

    my $request  = $self->{url} . '/api/' . $api . '/' . $method . '?apikey=' . $self->{apikey};
    my $response = $self->{ua}->get($request);
    if ($response->is_success) {
        my $hash = decode_json $response->decoded_content;
        if ($hash->{code} == 0) {
            # Change in the API, without documentation
            my $data = (ref($hash->{data}) eq 'HASH') ? $hash->{data}->{padIDs} : $hash->{data};
            return (wantarray) ? @{$data} : $data;
        } else {
            carp $hash->{message};
        }
    }
    else {
        carp $response->status_line;
    }
}


#################### footer pod documentation begin ###################
=head1 BUGS and SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Etherpad::API

Bugs and feature requests will be tracked at RT:

    http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Etherpad-API
    bug-etherpad-api at rt.cpan.org

The latest source code can be browsed and fetched at:

    https://github.com/ldidry/etherpad-api
    git clone git://github.com/ldidry/etherpad-api.git

You can also look for information at:

    RT: CPAN's request tracker

    http://rt.cpan.org/NoAuth/Bugs.html?Dist=Etherpad-API
    AnnoCPAN: Annotated CPAN documentation

    http://annocpan.org/dist/Etherpad-API
    CPAN Ratings

    http://cpanratings.perl.org/d/Etherpad-API
    Search CPAN

    http://search.cpan.org/dist/Etherpad-API


=head1 AUTHOR

    Luc DIDRY
    CPAN ID: LDIDRY
    ldidry@cpan.org
    http://www.fiat-tux.fr/

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

#################### footer pod documentation end ###################


1;

