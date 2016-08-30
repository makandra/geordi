desc 'eurest', 'Open the current Eurest cantina menu', :hide => true
def eurest
  Util.system! %{file="Speiseplan_KW`date +%V`.pdf" && wget -O/tmp/$file http://www.eurest-extranet.de/eurest/export/sites/default/sigma-technopark/de/downloads/$file && xdg-open /tmp/$file}
end
