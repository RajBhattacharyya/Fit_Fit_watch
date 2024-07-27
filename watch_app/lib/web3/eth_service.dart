import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

final ethServiceProvider = Provider<EthService>((ref) {
  return EthService();
});

class EthService {
  final String _rpcUrl = "https://rpc-amoy.polygon.technology/";
  final String _privateKey =
      "963a24ae791ac2fd16fb5d6e31e3af45651820a86426a2e7a4e0e4f4d10f0f7c";

  late Web3Client _client;
  late Credentials _credentials;
  late EthereumAddress _receiverContract;
  late EthereumAddress _senderContract;

  EthService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _client = Web3Client(_rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(_privateKey);
    String receiverAddress = await getAddress();
    _receiverContract = EthereumAddress.fromHex(receiverAddress);
    _senderContract =
        EthereumAddress.fromHex("0xBA5B2e5bE46ECCeD96b6AF1ABce45D72c1757f07");
  }

  Future<String> getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.getString('address') ?? '';
    return address;
  }

  Future<BigInt> getBalance() async {
    await _initialize();
    final balance = await _client.getBalance(_receiverContract);
    return balance.getInWei;
  }

  Future<String> sendEther(BigInt amount) async {
    await _initialize();
    final txHash = await _client.sendTransaction(
      _credentials,
      Transaction(
        to: _receiverContract,
        value: EtherAmount.inWei(amount),
      ),
      chainId: 80002,
    );
    return txHash;
  }
}
