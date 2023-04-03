1. insights start with scale of 4 pods - should we not start it with scale =1



2. when installing xray I am getting this error - could we not avoid it by setting something to the values?

************************************* WARNING *****************************************
* Your Xray master key is still set to the provided example:                          *
* xray.masterKey=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF     *
*                                                                                     *
* You should change this to your own generated key:                                   *
* $ export MASTER_KEY=$(openssl rand -hex 32)                                         *
* $ echo ${MASTER_KEY}                                                                *
*                                                                                     *
* Pass the created master key to helm with '--set xray.masterKey=${MASTER_KEY}'       *
***************************************************************************************

3. xray shows 6 pods - can we reduce it to 1?

4. where are these files?
kubectl cp -c xray-server comp_0.zip xray-0:/var/opt/jfrog/xray/work/server/updates/component/
kubectl cp -c xray-server vuln_0.zip xray-0:/var/opt/jfrog/xray/work/server/updates/vulnerability/