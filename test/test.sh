rm *.req*
fift -s ../generate-key.fif 1 new
fift -s ../generate-key.fif 2 new
fift -s ../generate-key.fif 3 new
fift -s ../generate-key.fif 4 new

func -P ../stdlib.fc ../multisig-code.fc  > multisig-code.fif
fift -s ../multi-wallet.fif 0 3 4 3 new
fift -s ../multi-wallet-request.fif new 1 EQB9w2tPnNCm4cXmlY98-haK3ProhZ4kQLiQGSRCZbTbn3hP 0.001 6000 -B TestMe
fift -s ../sign-request.fif 1 1 new
echo fift -s ../sign-request.fif 2 1 new
fift -s ../multi-wallet-build.fif 1 4 3 new


fift -s test.fif
