docker run -it --name IBMInformixContainer --privileged --restart=always -p 9088:9088 -e LICENSE=accept -e INFORMIX_PASSWORD=!Aa112233 ibmcom/informix-developer-database:latest