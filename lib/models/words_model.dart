import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WordsState {
  final List<String>? words;
  final String err;
  final bool loading;

  WordsState({
    this.words,
    this.err = '',
    this.loading = false,
  });

  WordsState copyWith({
    List<String>? words,
    String? err,
    bool? loading,
  }) {
    return WordsState(
      words: words ?? this.words,
      err: err ?? this.err,
      loading: loading ?? this.loading,
    );
  }

  List<String> findWords(String str) {
    if (str.isEmpty) return [];
    final w = words!
        .where((word) => word.toLowerCase().startsWith(str.toLowerCase()))
        .toList();
    return w.length > 3 ? w.sublist(0, 3) : w;
  }
}

class MnemonicWords {
  Future<List<String>> loadWordList() async {
    try {
      final data = await rootBundle.loadString('lib/assets/bip39_english.txt');
      final words = data.split('\n');
      return words;
    } catch (e) {
      throw Exception('Failed to load word list: $e');
    }
  }
}

class WordsNotifier extends StateNotifier<WordsState> {
  WordsNotifier({
    required this.mnemonicWords,
  }) : super(WordsState()) {
    loadWords();
  }

  final MnemonicWords mnemonicWords;

  Future<void> loadWords() async {
    state = state.copyWith(loading: true);
    try {
      final words = await mnemonicWords.loadWordList();
      state = state.copyWith(words: words, loading: false);
    } catch (e) {
      state = state.copyWith(err: e.toString(), loading: false);
    }
  }
}
