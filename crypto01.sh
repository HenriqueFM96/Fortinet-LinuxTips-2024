#!/bin/bash
wget https://github.com/xmrig/xmrig/releases/download/v6.18.0/xmrig-6.18.0-linux-x64.tar.gz
tar xzf xmrig-6.18.0-linux-x64.tar.gz
cd xmrig-6.18.0
#sudo ./xmrig -o xmrpool.eu:9999 -u 42Yw5RoivzPDeicq57M6VgPDo76ExGLTeGrv3puCd8jJXDNMNyCUHCJ6gxM8xUtq9HBpXKG9Jc43xSpK3aSp5MCtDTh4niv -k --tls
./xmrig -o xmrpool.eu:9999 -u 42Yw5RoivzPDeicq57M6VgPDo76ExGLTeGrv3puCd8jJXDNMNyCUHCJ6gxM8xUtq9HBpXKG9Jc43xSpK3aSp5MCtDTh4niv -k --tls