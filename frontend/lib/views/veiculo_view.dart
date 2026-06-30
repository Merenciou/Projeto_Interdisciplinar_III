import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/veiculo.dart';
import '../viewmodels/veiculo_viewmodel.dart';

class VeiculoView extends ConsumerStatefulWidget {
  const VeiculoView({super.key});

  @override
  ConsumerState<VeiculoView> createState() => _VeiculoViewState();
}

class _VeiculoViewState extends ConsumerState<VeiculoView> {
  final _placaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _corController = TextEditingController();
  final _anoController = TextEditingController();
  final _modeloController = TextEditingController();
  final _nChassiController = TextEditingController();
  bool _unicoDono = false;

  @override
  void dispose() {
    _placaController.dispose();
    _nomeController.dispose();
    _corController.dispose();
    _anoController.dispose();
    _modeloController.dispose();
    _nChassiController.dispose();
    super.dispose();
  }

  void _fillFields(Veiculo veiculo) {
    _placaController.text = veiculo.placa;
    _nomeController.text = veiculo.nome;
    _corController.text = veiculo.cor;
    _anoController.text = veiculo.ano.toString();
    _modeloController.text = veiculo.modelo.toString();
    _nChassiController.text = veiculo.nChassi;
    setState(() => _unicoDono = veiculo.unicoDono);
  }

  void _clearFields() {
    _placaController.clear();
    _nomeController.clear();
    _corController.clear();
    _anoController.clear();
    _modeloController.clear();
    _nChassiController.clear();
    setState(() => _unicoDono = false);
  }

  bool _validateFields() {
    return _placaController.text.isNotEmpty &&
        _nomeController.text.isNotEmpty &&
        _corController.text.isNotEmpty &&
        _anoController.text.isNotEmpty &&
        _modeloController.text.isNotEmpty &&
        _nChassiController.text.isNotEmpty;
  }

  Veiculo _buildVeiculo() {
    return Veiculo(
      placa: _placaController.text,
      nome: _nomeController.text,
      cor: _corController.text,
      ano: int.parse(_anoController.text),
      modelo: int.parse(_modeloController.text),
      nChassi: _nChassiController.text,
      unicoDono: _unicoDono,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(veiculoProvider);
    final viewModel = ref.read(veiculoProvider.notifier);

    ref.listen(veiculoProvider, (previous, next) {
      if (next.message.isNotEmpty) {
        _showMessage(next.message);
        viewModel.clearMessage();
      }
      if (next.selectedVeiculo != null &&
          previous?.selectedVeiculo != next.selectedVeiculo) {
        _fillFields(next.selectedVeiculo!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Veículos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(_placaController, 'Placa'),
            _buildTextField(_nomeController, 'Nome'),
            _buildTextField(_corController, 'Cor'),
            _buildTextField(_anoController, 'Ano', isNumber: true),
            _buildTextField(_modeloController, 'Modelo', isNumber: true),
            _buildTextField(_nChassiController, 'Número do Chassi'),
            SwitchListTile(
              title: const Text('Único Dono'),
              value: _unicoDono,
              onChanged: (value) => setState(() => _unicoDono = value),
            ),
            const SizedBox(height: 24),
            if (state.isLoading)
              const CircularProgressIndicator()
            else
              _buildButtons(viewModel, state),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildButtons(VeiculoViewModel viewModel, VeiculoState state) {
    final hasSelected = state.selectedVeiculo != null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (!_validateFields()) {
                    _showMessage('Preencha todos os campos.');
                    return;
                  }
                  await viewModel.save(_buildVeiculo());
                  _clearFields();
                },
                child: const Text('Salvar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (_placaController.text.isEmpty) {
                    _showMessage('Informe a placa para pesquisar.');
                    return;
                  }
                  await viewModel.search(_placaController.text);
                },
                child: const Text('Pesquisar'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: hasSelected
                    ? () async {
                        if (!_validateFields()) {
                          _showMessage('Preencha todos os campos.');
                          return;
                        }
                        await viewModel.update(
                          state.selectedVeiculo!.placa,
                          _buildVeiculo(),
                        );
                        _clearFields();
                      }
                    : null,
                child: const Text('Alterar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: hasSelected
                    ? () async {
                        await viewModel.delete(state.selectedVeiculo!.placa);
                        _clearFields();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Excluir'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await viewModel.downloadTxt();
            },
            icon: const Icon(Icons.download),
            label: const Text('Baixar TXT'),
          ),
        ),
      ],
    );
  }
}
