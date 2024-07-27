import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch_app/web3/eth_service.dart';

final balanceProvider = StateNotifierProvider<BalanceNotifier, BigInt>((ref) {
  final ethService = ref.watch(ethServiceProvider);
  return BalanceNotifier(ethService);
});

class BalanceNotifier extends StateNotifier<BigInt> {
  final EthService _ethService;

  BalanceNotifier(this._ethService) : super(BigInt.zero) {
    _updateBalance();
  }

  Future<void> _updateBalance() async {
    state = await _ethService.getBalance();
  }

  Future<void> sendEther(BigInt amount) async {
    await _ethService.sendEther(amount);
    _updateBalance();
  }
}
