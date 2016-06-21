package Yubin::UserAgent::EWS::Requests;
use Moose::Role;

# use Sub::Exporter::ForMethods qw( method_installer );
# use Data::Section { installer => method_installer }, -setup;

use Data::Section::Simple qw(get_data_section);
 
use Text::Xslate;
use Path::Tiny;

has 'tx' => ( is => 'ro', default => sub { Text::Xslate->new() } );

sub data_section {
    my $self = shift;
    my $template = shift;
    # print STDERR '-' x 80;
    return get_data_section($template);
};


sub compile {
    my ($self, $template, $data) = @_;
    # print STDERR "#1 $template";
    if (-f $template) {
	$template = path($template)->slurp
    } else {
	$template = $self->data_section($template);
	# print STDERR "#3 $template";
    };
    my $text = $self->tx->render_string($template, $data);
    return $text;
}

1;

__DATA__
@@ get_manager
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	       xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
	       xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">
  <soap:Header>
    <t:RequestServerVersion Version="Exchange2013_SP1" />
  </soap:Header>
  <soap:Body>
    <ResolveNames xmlns="http://schemas.microsoft.com/exchange/services/2006/messages"
                  xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types"
		  ReturnFullContactData="true" SearchScope="ActiveDirectory" ContactDataShape="AllProperties">
      <UnresolvedEntry><: $name :></UnresolvedEntry>
    </ResolveNames>
  </soap:Body>
</soap:Envelope>
@@ get_manager_not_working
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types"
               xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages">
   <soap:Header>
    <t:RequestServerVersion Version="Exchange2013" />
   </soap:Header>
   <soap:Body >
    <m:FindItem  Traversal="Shallow">
      <m:ItemShape>
        <t:BaseShape>IdOnly</t:BaseShape>
      </m:ItemShape>
      <m:Restriction>
	<t:Contains ContainmentMode="Substring" ContainmentComparison="IgnoreCase">
	  <t:FieldURI FieldURI="contacts:Manager" />
	  <t:Constant Value="gaudio" />
	</t:Contains>
      </m:Restriction>
      <m:ParentFolderIds>
        <t:DistinguishedFolderId Id="directory"/>
      </m:ParentFolderIds>
    </m:FindItem>
   </soap:Body>
</soap:Envelope>
@@ resolve_name
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	       xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">
  <soap:Body>
    <ResolveNames xmlns="http://schemas.microsoft.com/exchange/services/2006/messages"
                  xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types"
                  ReturnFullContactData="true">
      <UnresolvedEntry><: $name :></UnresolvedEntry>
    </ResolveNames>
  </soap:Body>
</soap:Envelope>
@@ find_meeting
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
       xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages" 
       xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types" 
       xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <m:FindItem Traversal="Shallow">
      <m:ItemShape>
        <t:BaseShape>IdOnly</t:BaseShape>
        <t:AdditionalProperties>
          <t:FieldURI FieldURI="item:Subject" />
          <t:FieldURI FieldURI="calendar:Start" />
          <t:FieldURI FieldURI="calendar:End" />
        </t:AdditionalProperties>
      </m:ItemShape>
      <m:Restriction>
          <t:Contains ContainmentMode="Substring" ContainmentComparison="IgnoreCase">
            <t:FieldURI FieldURI="item:Subject" />
            <t:Constant Value="<: $name :>" />
          </t:Contains>
      </m:Restriction>
      <m:ParentFolderIds>
	<t:DistinguishedFolderId Id="calendar" />
      </m:ParentFolderIds>
    </m:FindItem>
  </soap:Body>
</soap:Envelope>
@@ get_meeting_responses
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
               xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages" 
               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types" 
               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
   <soap:Body>
      <m:GetItem>
         <m:ItemShape>
            <t:BaseShape>AllProperties</t:BaseShape>
         </m:ItemShape>
         <m:ItemIds>
            <t:ItemId Id="<: $id :>" />
         </m:ItemIds>
      </m:GetItem>
   </soap:Body>
</soap:Envelope>
@@ send_mail
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
               xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages" 
               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types" 
               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Header>
    <t:RequestServerVersion Version="Exchange2007_SP1" />
  </soap:Header>
  <soap:Body>
    <m:CreateItem MessageDisposition="SendAndSaveCopy">
      <m:SavedItemFolderId><t:DistinguishedFolderId Id="sentitems"/></m:SavedItemFolderId><m:Items>
        <t:Message>
          <t:Subject><: $subject :></t:Subject>
          <t:Body BodyType="HTML"><: $body :></t:Body>
          <t:ToRecipients>
	  : for $to -> $item {
	  <t:Mailbox><t:EmailAddress><:$item.email:></t:EmailAddress></t:Mailbox>
	  : }
          </t:ToRecipients>
	  : if $cc != nil {
          <t:CcRecipients>
	  : for $cc -> $item {
          <t:Mailbox><t:EmailAddress><: $item.email :></t:EmailAddress></t:Mailbox>
	  : }
          </t:CcRecipients>
	  : }
        </t:Message>
      </m:Items>
    </m:CreateItem>
  </soap:Body>
</soap:Envelope>
@@ get_item
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
               xmlns:m="http://schemas.microsoft.com/exchange/services/2006/messages" 
               xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types" 
               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Header>
    <t:RequestServerVersion Version="Exchange2007_SP1" />
    </soap:Header>
  <soap:Body>
    <m:GetItem>
      <m:ItemShape>
        <t:BaseShape>IdOnly</t:BaseShape>
        <t:AdditionalProperties>
          <t:FieldURI FieldURI="item:Subject" />
        </t:AdditionalProperties>
      </m:ItemShape>
      <m:ItemIds>
        <t:ItemId Id="<: $id :>" />
      </m:ItemIds>
    </m:GetItem>
  </soap:Body>
</soap:Envelope>
@@ autodiscover
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:a="http://schemas.microsoft.com/exchange/2010/Autodiscover" 
        xmlns:wsa="http://www.w3.org/2005/08/addressing" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
        xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Header>
    <a:RequestedServerVersion>Exchange2010</a:RequestedServerVersion>
    <wsa:Action>http://schemas.microsoft.com/exchange/2010/Autodiscover/Autodiscover/GetUserSettings</wsa:Action>
    <wsa:To>https://autodiscover.adidas-group.com/autodiscover/autodiscover.svc</wsa:To>
  </soap:Header>
  <soap:Body>
    <a:GetUserSettingsRequestMessage xmlns:a="http://schemas.microsoft.com/exchange/2010/Autodiscover">
      <a:Request>
        <a:Users>
          <a:User>
            <a:Mailbox><: $email :></a:Mailbox>
          </a:User>
        </a:Users>
        <a:RequestedSettings>
          <a:Setting>UserDisplayName</a:Setting>
          <a:Setting>UserDN</a:Setting>
          <a:Setting>UserDeploymentId</a:Setting>
          <a:Setting>InternalMailboxServer</a:Setting>
          <a:Setting>MailboxDN</a:Setting>
          <a:Setting>PublicFolderServer</a:Setting>
          <a:Setting>ActiveDirectoryServer</a:Setting>
          <a:Setting>ExternalMailboxServer</a:Setting>
          <a:Setting>EcpDeliveryReportUrlFragment</a:Setting>
          <a:Setting>EcpPublishingUrlFragment</a:Setting>
          <a:Setting>EcpTextMessagingUrlFragment</a:Setting>
          <a:Setting>ExternalEwsUrl</a:Setting>
          <a:Setting>CasVersion</a:Setting>
          <a:Setting>EwsSupportedSchemas</a:Setting>
        </a:RequestedSettings>
      </a:Request>
    </a:GetUserSettingsRequestMessage>
  </soap:Body>
</soap:Envelope>    

    
