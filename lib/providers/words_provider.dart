import 'package:Satsails/models/words_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mnemonicWordsProvider = Provider.autoDispose<MnemonicWords>((ref) {
  return MnemonicWords();
});

final wordsProvider = StateNotifierProvider.autoDispose<WordsNotifier, WordsState>((ref) {
  final mnemonicWords = ref.watch(mnemonicWordsProvider);
  return WordsNotifier(mnemonicWords: mnemonicWords);
});