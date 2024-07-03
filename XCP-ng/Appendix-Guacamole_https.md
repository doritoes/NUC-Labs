# Appendix - Convert Guacamole to https

References:
- https://docs.bitnami.com/aws/apps/guacamole/administration/enable-ssl-tomcat/
- https://tomcat.apache.org/tomcat-9.0-doc/ssl-howto.html
- https://crunchify.com/step-by-step-guide-to-enable-https-or-ssl-correct-way-on-apache-tomcat-server-port-8443/

# Steps
- Create keystore
  - `sudo keytool -genkey -alias guacamole -keyalg RSA -keystore /etc/guacamole/guacamole.keystore`
    - keystore password: guacamolepassword
    - provide the requested data
- Create Self Signed Certificate Signing Request
  - `sudo keytool -certreq -keyalg RSA -alias guacamole -file guacamole.csr -keystore /etc/guacamole/guacamole.keystore`
    - enter password guacamolepassword
- Update server.xml file
  - sudo vi /etc/tomcat9/server.xml
  - Add this section below an existing Connector definition
```
<Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true"
               maxThreads="150" scheme="https" secure="true"
               keystoreFile="/etc/guacamole/guacamole.keystore" keystorePass="guacamolepassword"
               clientAuth="false" sslProtocol="TLS" sslVerifyClient="optional"
               sslEnabledProtocols="TLSv1.2,TLSv1.1,SSLv2Hello"/>
```
- Restart Apache Tomcat
  - `sudo systemctl restart tomcat9`
- Connect on to the guacamole changing the port to 8443
  - Example: `https://<IPADDRESS>:8443`
NOTE If you created port forwarding on the Lab router to be able to access the guacamole from outside, you will need to add or modify it for port 8443.

# Forcing http to https Redirect
- `sudo vi /etc/tomcat9/web.xml`
- add the following content at the end of the file before the closing </web-app>
~~~
<security-constraint>
<web-resource-collection>
<web-resource-name>Protected Context</web-resource-name>
<url-pattern>/*</url-pattern>
</web-resource-collection>
<!-- auth-constraint goes here if you requre authentication -->
<user-data-constraint>
<transport-guarantee>CONFIDENTIAL</transport-guarantee>
</user-data-constraint>
</security-constraint>
~~~
- `sudo systemctl restart tomcat9`
- Clear your browsers cookies and cache to resolve any cached redirects
- Confirm the redirect from port http and 8080 to https and port 8443 is working
