insights start with scale of 4 pods - should we not start it with scale =1



when installing xray I am getting this error - could we not avoid it by setting something to the values?

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
