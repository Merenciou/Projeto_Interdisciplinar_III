class Veiculo {
  final String placa;
  final String nome;
  final String cor;
  final int ano;
  final int modelo;
  final String nChassi;
  final bool unicoDono;

  Veiculo({
    required this.placa,
    required this.nome,
    required this.cor,
    required this.ano,
    required this.modelo,
    required this.nChassi,
    required this.unicoDono,
  });

  factory Veiculo.fromJson(Map<String, dynamic> json) {
    return Veiculo(
      placa: json['placa'],
      nome: json['nome'],
      cor: json['cor'],
      ano: json['ano'],
      modelo: json['modelo'],
      nChassi: json['n_chassi'],
      unicoDono: json['unico_dono'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placa': placa,
      'nome': nome,
      'cor': cor,
      'ano': ano,
      'modelo': modelo,
      'n_chassi': nChassi,
      'unico_dono': unicoDono,
    };
  }
}
