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

chaincodeTransferProductSolveModel() {
    echo "===================== Started SolveModel Transferred Chaincode Function========== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["solveModel", "3","4", "41,35,96", "{{2, 3, 7}, {1, 1, 0}, {5, 3, 0}, {0.6, 0.25, 1}}" ,"1250,250,900,232.5" ]}'
    echo "===================== Successfully SolveModel Transferred Chaincode Function========== "
}

chaincodeTransferProductOwnership
sleep 5
chaincodePurchaseSomeProduct
sleep 5
chaincodeTransferProductSolveModel
