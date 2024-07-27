import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

final ethServiceProvider = Provider<EthService>((ref) {
  return EthService();
});

class EthService {
  final String _rpcUrl = "https://rpc-amoy.polygon.technology/"; // Polygon Mumbai testnet RPC URL
  final String _privateKey = "963a24ae791ac2fd16fb5d6e31e3af45651820a86426a2e7a4e0e4f4d10f0f7c"; // Replace with your wallet private key

  late Web3Client _client;
  late Credentials _credentials;
  late EthereumAddress _receiverContract;
  late EthereumAddress _senderContract;

  EthService() {
    _client = Web3Client(_rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(_privateKey);
    _receiverContract = EthereumAddress.fromHex("0xA0e793E7257c065b30c46Ef6828F2B3C0de87A8E");
    _senderContract = EthereumAddress.fromHex("0xBA5B2e5bE46ECCeD96b6AF1ABce45D72c1757f07");
  }

  Future<BigInt> getBalance() async {
    final balance = await _client.getBalance(_receiverContract);
    return balance.getInWei;
  }

  Future<String> sendEther(BigInt amount) async {
    final txHash = await _client.sendTransaction(
      _credentials,
      Transaction(
        to: _receiverContract,
        value: EtherAmount.inWei(amount),
      ),
      chainId: 80002, // Chain ID for Polygon Mumbai testnet
    );
    return txHash;
  }
}
