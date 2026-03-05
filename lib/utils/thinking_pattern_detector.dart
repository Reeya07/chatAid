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
      t.contains("completely") ||
      t.contains("i always") ||
      t.contains("i never") ||
      t.contains("i can't do anything right") ||
      t.contains("i am a failure") ||
      t.contains("i'm a failure") ||
      t.contains("everything is ruined")) {
    allOrNothing += 2;
  }
  //Mind Reading
  if (t.contains("they think") ||
      t.contains("they must") ||
      t.contains("everyone will") ||
      t.contains("hate me") ||
      t.contains("judge me") ||
      t.contains("they will judge") ||
      t.contains("they will think") ||
      t.contains("people will think") ||
      t.contains("they will hate me") ||
      t.contains("everyone thinks")) {
    mindReading += 2;
  }
  //Catastrophizing
  if (t.contains("what if") ||
      t.contains("worst") ||
      t.contains("ruin") ||
      t.contains("can't handle") ||
      t.contains("disaster") ||
      t.contains("i will fail") ||
      t.contains("going to fail") ||
      t.contains("i'm going to fail") ||
      t.contains("im going to fail") ||
      t.contains("everything will go wrong") ||
      t.contains("this will go wrong") ||
      t.contains("i won't survive") ||
      t.contains("i won't manage") ||
      t.contains("fail my exam") ||
      t.contains("fail the test")) {
    catastrophizing += 2;
  }
  //overgeneralization
  if (t.contains("everyone") ||
      t.contains("nobody") ||
      t.contains("everything") ||
      t.contains("every time") ||
      t.contains("nothing ever") ||
      t.contains("this always happens") ||
      t.contains("things never work") ||
      t.contains("this happens every time")) {
    overgeneral += 2;
  }
  //Should Statement
  if (t.contains("should") ||
      t.contains("must") ||
      t.contains("have to") ||
      t.contains("supposed to") ||
      t.contains("i need to") ||
      t.contains("i ought to") ||
      t.contains("i shouldn't")) {
    shouldStatements += 2;
  }
  //personalization
  if (t.contains("my fault") ||
      t.contains("because of me") ||
      t.contains("i caused") ||
      t.contains("i ruin") ||
      t.contains("it's my fault") ||
      t.contains("this is my fault") ||
      t.contains("i messed up") ||
      t.contains("i made it worse")) {
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
