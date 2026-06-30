import 'package:flutter_riverpod/legacy.dart';
import '../models/veiculo.dart';
import '../services/veiculo_service.dart';

class VeiculoState {
  final Veiculo? selectedVeiculo;
  final String message;
  final bool isLoading;

  VeiculoState({
    this.selectedVeiculo,
    this.message = '',
    this.isLoading = false,
  });

  VeiculoState copyWith({
    Veiculo? selectedVeiculo,
    String? message,
    bool? isLoading,
    bool clearVeiculo = false,
  }) {
    return VeiculoState(
      selectedVeiculo: clearVeiculo
          ? null
          : selectedVeiculo ?? this.selectedVeiculo,
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class VeiculoViewModel extends StateNotifier<VeiculoState> {
  final VeiculoService _service;

  VeiculoViewModel(this._service) : super(VeiculoState());

  Future<void> downloadTxt() async {
    state = state.copyWith(isLoading: true);
    final result = await _service.downloadTxt();
    state = state.copyWith(isLoading: false, message: result);
  }

  Future<void> save(Veiculo veiculo) async {
    state = state.copyWith(isLoading: true);
    final result = await _service.salvar(veiculo);
    state = state.copyWith(isLoading: false, message: result['message']);
  }

  Future<void> search(String placa) async {
    state = state.copyWith(isLoading: true);
    final result = await _service.pesquisar(placa);
    if (result != null) {
      state = state.copyWith(
        isLoading: false,
        selectedVeiculo: result,
        message: 'Veículo encontrado.',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        message: 'Veículo não encontrado.',
        clearVeiculo: true,
      );
    }
  }

  Future<void> update(String placa, Veiculo veiculo) async {
    state = state.copyWith(isLoading: true);
    final result = await _service.alterar(placa, veiculo);
    state = state.copyWith(isLoading: false, message: result['message']);
  }

  Future<void> delete(String placa) async {
    state = state.copyWith(isLoading: true);
    final result = await _service.excluir(placa);
    state = state.copyWith(
      isLoading: false,
      message: result['message'],
      clearVeiculo: true,
    );
  }

  void clearMessage() {
    state = state.copyWith(message: '');
  }
}

final veiculoProvider = StateNotifierProvider<VeiculoViewModel, VeiculoState>(
  (ref) => VeiculoViewModel(VeiculoService()),
);
