import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Identification extends ConsumerStatefulWidget {
  const Identification({Key? key}) : super(key: key);

  @override
  _IdentificationState createState() => _IdentificationState();
}

class _IdentificationState extends ConsumerState<Identification> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final currentIdentification = ref.read(settingsProvider).identificationBr;
    _controller = TextEditingController(text: currentIdentification);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Editar Identificação'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Guardaremos esta informação nos nossos servidores para conseguirmos pagar-lhe seu PIX. Se não quiser guardar, não poderá usar PIX.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Não está a expor nenhuma informação pessoal. Apenas o seu CPF ou CNPJ será salvo. Nenhum dos seus dados da carteira será guardado.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Insira seu CPF ou CNPJ para identificação. Uma vez salvo, não poderá ser alterado.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Identificação (CPF/CNPJ)',
                  hintText: 'Digite seu CPF ou CNPJ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.redAccent, Colors.orangeAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    final newIdentification = _controller.text;
                    bool isValid = newIdentification.length <= 11
                        ? CPFValidator.isValid(newIdentification)
                        : CNPJValidator.isValid(newIdentification);

                    if (isValid) {
                      final strippedIdentification = newIdentification.length <= 11
                          ? CPFValidator.strip(newIdentification)
                          : CNPJValidator.strip(newIdentification);
                      ref.read(settingsProvider.notifier).setidentificationBr(strippedIdentification);
                      Navigator.pop(context);
                    } else {
                      Fluttertoast.showToast(msg: 'CPF ou CNPJ inválido');
                    }
                  },
                  child: const Text(
                    'Salvar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
