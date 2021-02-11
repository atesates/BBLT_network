

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



chaincodeTransferProductSolveModel() {
    echo "===================== Started SolveModel Transferred Chaincode Function========== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["solveMyModel", "3","4", "41,35,96", "{{2, 3, 7}, {1, 1, 0}, {5, 3, 0}, {0.6, 0.25, 1}}" ,"1250,250,900,232.5" ]}'
    echo "===================== Successfully SolveModel Transferred Chaincode Function========== "
}

chaincodeTransferProductSolveModel
