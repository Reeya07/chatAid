class ThinkingPattern {
  final String label;
  final double confidence;

  ThinkingPattern(this.label, this.confidence);
}

ThinkingPattern detectPattern(String thought) {
  final t = thought.toLowerCase();

  double allOrNothing = 0;
  double catastrophizing = 0;
  double mindReading = 0;
  double overgeneral = 0;
  double shouldStatements = 0;
  double personalization = 0;

  //All or Nothing
  if (t.contains("always") ||
      t.contains("never") ||
      t.contains("nothing") ||
      t.contains("completely")) {
    allOrNothing += 2;
  }
  //Mind Reading
  if (t.contains("they think") ||
      t.contains("they must") ||
      t.contains("everyone will") ||
      t.contains("hate me") ||
      t.contains("judge me")) {
    mindReading += 2;
  }
  //Catastrophizing
  if (t.contains("what if") ||
      t.contains("worst") ||
      t.contains("ruin") ||
      t.contains("can't handle") ||
      t.contains("disaster")) {
    catastrophizing += 2;
  }
  //overgeneralization
  if (t.contains("everyone") ||
      t.contains("nobody") ||
      t.contains("everything") ||
      t.contains("every time")) {
    overgeneral += 2;
  }
  //Should Statement
  if (t.contains("should") ||
      t.contains("must") ||
      t.contains("have to") ||
      t.contains("supposed to")) {
    shouldStatements += 2;
  }
  //personalization
  if (t.contains("my fault") ||
      t.contains("because of me") ||
      t.contains("i caused") ||
      t.contains("i ruin")) {
    personalization += 2;
  }

  final scores = <String, double>{
    "All or Nothing thinking": allOrNothing,
    "Catastrophizing": catastrophizing,
    "Mind Reading": mindReading,
    "Overgeneralization": overgeneral,
    "Should statements": shouldStatements,
    "Personalization": personalization,
  };
  String bestLabel = "Unclear";
  double bestScore = 0;

  scores.forEach((label, score) {
    if (score > bestScore) {
      bestScore = score;
      bestLabel = label;
    }
  });
  final confidence = (bestScore >= 2) ? 0.8 : 0.3;
  return ThinkingPattern(bestLabel, confidence);
}
