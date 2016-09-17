use ExtUtils::MakeMaker;
WriteMakefile(
	      NAME            => 'Yubin',
	      VERSION_FROM    => 'lib/Yubin.pm',
	      PREREQ_PM       => {
				  "Authen::NTLM" => 0,
				  "Data::Dump" => 0,
				  "Data::Section" => 0,
				  "Data::Section::Simple" => 0,
				  "ExtUtils::MakeMaker" => 0,
				  "HTTP::Request" => 0,
				  "HTTP::Response" => 0,
				  "JSON" => 0,
				  "LWP::UserAgent" => 0,
				  "Moose::Role" => 0,
				  "Moose" => 0,
				  "Path::Tiny" => 0,
				  "Sub::Exporter::ForMethods" => 0,
				  "Text::Xslate" => 0,
				  "Want" => 0,
				  "XML::Bare" => 0,
				  "XML::LibXML" => 0,
				  }
	     );
