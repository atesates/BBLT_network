sudo rm -rf /home/ates/eclipse-workspace/fabricjavaclientproduct/wallet/*

export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/../config/
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export ORDERER_ADDRESS=localhost:7050
export CORE_PEER_TLS_ROOTCERT_FILE_ORG1=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE_ORG2=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

CHANNEL_NAME="samplechannel"
CHAINCODE_NAME="ProductTransfer"
CHAINCODE_VERSION="1"
CHAINCODE_PATH="../chaincode/producttransfer/build/install/producttransfer"
CHAINCODE_LANG="java"
CHAINCODE_LABEL="medicinetransfer_1"

setEnvVarsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE_ORG1}
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setEnvVarsForPeer0Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE_ORG2
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

packageChaincode() {
    echo "===================== Started to package the Chaincode on peer0.org1 ===================== "
    rm -rf ${CHAINCODE_NAME}.tar.gz
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path ${CHAINCODE_PATH} --lang ${CHAINCODE_LANG} --label ${CHAINCODE_LABEL}
    echo "===================== Chaincode is packaged on peer0.org1 ===================== "
}

installChaincode() {
    echo "===================== Started to Install Chaincode on peer0.org1 ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz\
    --peerAddresses $CORE_PEER_ADDRESS --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1
    echo "===================== Chaincode is installed on peer0.org1 ===================== "
    
    
    echo "===================== Started to Install Chaincode on peer0.org2 ===================== "
    setEnvVarsForPeer0Org2
    peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz\
    --peerAddresses $CORE_PEER_ADDRESS --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2
    echo "===================== Chaincode is installed on peer0.org2 ===================== "
    
}

queryInstalled() {
    echo "===================== Started to Query Installed Chaincode on peer0.org1 ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode queryinstalled --peerAddresses $CORE_PEER_ADDRESS\
    --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1 >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CHAINCODE_LABEL}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 ===================== "
}

approveForMyOrg1() {
    echo "===================== Started to approve chaincode definition from org 1 ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA\
    --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION}\
    --init-required --package-id ${PACKAGE_ID} --sequence 1

    echo "===================== chaincode approved from org 1 ===================== "

}

checkCommitReadynessForOrg1() {
    echo "===================== Started to check commit readyness from org 1 ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME}\
    --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence 1 --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

approveForMyOrg2() {
    echo "===================== Started to approve chaincode definition from org 2 ===================== "
    setEnvVarsForPeer0Org2
    peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA\
    --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION}\
    --init-required --package-id ${PACKAGE_ID} --sequence 1
    echo "===================== chaincode approved from org 2 ===================== "
}

checkCommitReadynessForOrg2() {
    echo "===================== Started to check commit readyness from org 2 ===================== "
    setEnvVarsForPeer0Org2
    peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME}\
    --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence 1 --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

commitChaincodeDefination() {
    echo "===================== Started to commit Chaincode definition on channel ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode commit -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    --version ${CHAINCODE_VERSION} --sequence 1 --init-required
    echo "===================== Chaincode definition committed on channel ===================== "
}

queryCommitted() {
    echo "===================== Started to query commintted chaincode definition on channel ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME}
    echo "===================== Queried the chaincode definition committed on channel ===================== "

}

chaincodeInvokeInit() {
    echo "===================== Started to Initilize chaincode===================== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    --isInit -c '{"Args":[]}'
    echo "===================== Succesfully Initilized the chaincode===================== "
}

chaincodeAddProduct() {
    echo "===================== Started Add Product Chaincode Function===================== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["addNewProduct", "Pharmacy1_AUGBID_01.01.2021", "AUGBID_01.01.2020","AUGBID",  "Pharmacy1","13","65","03.03.2033","01.03.2020","on sale", "03.04.2020","Pharmacy1",  "null" ]}'
    echo "===================== Successfully Added New Product===================== "
}

chaincodeQueryProductById() {
    echo "===================== Started Query Product By Id Chaincode Function===================== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["queryProductById", "Pharmacy1_AUGBID_01.01.2021"]}'
    echo "===================== Successfully Invoked Query Product By Id Chaincode Function===================== "
}

chaincodeTransferProductOwnership() {
    echo "===================== Started Product Ownership Transferred Chaincode Function===================== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["changeProductOwnership", "Pharmacy1_AUGBID_01.01.2021","Pharmacy2"]}'
    echo "===================== Successfully Product Ownership Transferred Chaincode Function===================== "
}

chaincodePurchaseSomeProduct() {
    echo "===================== Started purchase Some Product Chaincode Function=============== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["purchaseSomeProduct", "Pharmacy1_AUGBID_01.01.2021", "Pharmacy3", "1"]}'
    echo "===================== Successfully purchased Some Product Chaincode Function===================== "
}

queryProduct() {
    echo "===================== Started Query All Product Chaincode Function=============== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["queryAllProducts"]}'
    echo "===================== Successfully Query All Product Product Chaincode Function===================== "
}

chaincodeTransferProductSolveModel() {
    echo "===================== Started SolveModel Transferred Chaincode Function========== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["solveMyModel", "Pharmacy1_AUGBID_01.01.2021", "3","4", "41,35,96", "{{2, 3, 7}, {1, 1, 0}, {5, 3, 0}, {0.6, 0.25, 1}}" ,"1250,250,900,232.5" ]}'
    echo "===================== Successfully SolveModel Transferred Chaincode Function========== "
}


chaincodePharmaciesSolveModel() {
    echo "===================== Started Pharmacies SolveModel Chaincode Function========== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["solveModel", "3","4", "41,35,96", "{{2, 30, 7}, {1, 1, 0}, {5, 3, 0}, {0.6, 0.25, 1}}" ,"1250,250,900,232.5" ]}'
    echo "===================== Successfully Pharmacies SolveModel Chaincode Function========== "
}
packageChaincode
installChaincode
queryInstalled
approveForMyOrg1
checkCommitReadynessForOrg1
approveForMyOrg2
checkCommitReadynessForOrg2
commitChaincodeDefination
queryCommitted
sleep 3
chaincodeInvokeInit
sleep 3
chaincodeAddProduct
sleep 3
chaincodeQueryProductById
sleep 3
chaincodeTransferProductOwnership
sleep 3
chaincodePurchaseSomeProduct
sleep 3
queryProduct
#sleep 5
#chaincodeTransferProductSolveModel
#sleep 5
#chaincodePharmaciesSolveModel