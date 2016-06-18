package Yubin::UserAgent::EWS::Requests;

use Moose::Role;
use Text::Xslate;
use Data::Section -setup;
use Path::Tiny;

has 'tx' => ( is => 'ro', default => sub { Text::Xslate->new() } );

sub compile {
    my ($self, $template, $data) = @_;
    print STDERR "#1 $template\n";
    if (-f $template) {
	$template = path($template)->slurp
    } else {
	print STDERR "#2 $template";
	print STDERR "#p " . __PACKAGE__;
	$template = ${__PACKAGE__->section_data($template)};
	print STDERR "#3 $template";
    };
    my $text = $self->tx->render_string($template, $data);
    return $text;
}

1;

__DATA__
__[ get_manager ]__
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
__[ get_manager_not_working ]__
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
__[ resolve_name ]__
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
__[ find_meeting ]__
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
__[ get_meeting_responses ]__
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
__[ send_mail ]__
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
__[ get_item ]__
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

