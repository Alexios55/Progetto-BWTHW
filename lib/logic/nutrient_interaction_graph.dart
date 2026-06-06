//  NUTRIENT INTERACTION GRAPH  (NIG)
//
//  Models cause-effect relationships between nutrients.
//  Each [NutrientEdge] connects a SOURCE nutrient to a TARGET nutrient with a signed weight:
//    +  synergistic  (source boosts target absorption / effect)
//    -  antagonistic (source inhibits target absorption / effect)
//
//  The engine calls [propagatedScore] to obtain the true effective contribution of a food to a blood parameter,
//  accounting for all first-degree interactions.
//
//  Literature references:
//  - Hallberg et al. (1989) — vitamin C and non-heme iron absorption
//  - Hallberg et al. (1991) — calcium inhibition of iron absorption
//  - Noonan & Savage (1999) — oxalate bioavailability
//  - Hurrell & Egli (2010)  — iron bioavailability / phytate inhibition

class NutrientEdge {
  // The nutrient that exerts the influence.
  final String source;

  // The nutrient whose absorption/effect is modified.
  final String target;

  // Signed interaction weight in [-1, +1].
  //   > 0  ->  synergistic
  //   < 0  ->  antagonistic
  final double weight;

  // A brief description of the interaction.
  final String description;

  const NutrientEdge({
    required this.source,
    required this.target,
    required this.weight,
    required this.description,
  });
}

class NutrientInteractionGraph {
  // Edge definitions 
  static const List<NutrientEdge> edges = [
    // Vitamin C strongly enhances non-heme iron absorption
    NutrientEdge(
      source: 'vitaminC',
      target: 'iron',
      weight: 0.30,
      description: 'Vitamin C reduces Fe³⁺ to Fe²⁺, increasing '
          'non-heme iron absorption by up to 3×.',
    ),
    // Calcium inhibits both heme and non-heme iron absorption
    NutrientEdge(
      source: 'calcium',
      target: 'iron',
      weight: -0.20,
      description: 'Calcium competes with iron at the intestinal '
          'transport level (DMT-1 transporter).',
    ),
    // Phytates inhibit iron, zinc, and calcium
    NutrientEdge(
      source: 'phytates',
      target: 'iron',
      weight: -0.25,
      description: 'Phytic acid chelates Fe²⁺, forming insoluble '
          'complexes that cannot be absorbed.',
    ),
    NutrientEdge(
      source: 'phytates',
      target: 'calcium',
      weight: -0.15,
      description: 'Phytic acid forms insoluble calcium-phytate '
          'complexes, reducing bioavailability.',
    ),
    // Oxalates inhibit calcium and iron absorption
    NutrientEdge(
      source: 'oxalates',
      target: 'calcium',
      weight: -0.20,
      description: 'Oxalic acid binds calcium forming insoluble '
          'calcium oxalate (e.g. in spinach).',
    ),
    NutrientEdge(
      source: 'oxalates',
      target: 'iron',
      weight: -0.10,
      description: 'Oxalates partially inhibit non-heme iron '
          'absorption.',
    ),
    // Vitamin D strongly enhances calcium absorption
    NutrientEdge(
      source: 'vitaminD',
      target: 'calcium',
      weight: 0.35,
      description: 'Vitamin D upregulates calbindin and TRPV6, '
          'the primary intestinal calcium channels.',
    ),
    // Omega-3 modulates LDL cholesterol (represented as 'cholesterol')
    NutrientEdge(
      source: 'omega3',
      target: 'cholesterol',
      weight: -0.20,
      description: 'EPA and DHA reduce hepatic VLDL secretion '
          'and increase LDL particle size.',
    ),
    // Fiber slows glucose absorption → beneficial for glycemia
    NutrientEdge(
      source: 'fiber',
      target: 'glucose',
      weight: -0.15,
      description: 'Soluble fiber forms viscous gel that slows '
          'glucose absorption and blunts glycemic response.',
    ),
  ];

  // Index for O(1) lookup: target -> list of edges 
  static final Map<String, List<NutrientEdge>> _byTarget = () {
    final map = <String, List<NutrientEdge>>{};
    for (final e in edges) {
      map.putIfAbsent(e.target, () => []).add(e);
    }
    return map;
  }();

  /// Returns all edges that influence [targetNutrient].
  static List<NutrientEdge> edgesFor(String targetNutrient) =>
      _byTarget[targetNutrient] ?? [];

  //  propagatedScore
  // 
  //  Computes the effective contribution of [foodNutrients] to [targetNutrient], propagating first-degree interactions.
  //
  //  Formula (per edge e with source s, weight w):
  //    Δscore(s→t) = foodNutrients[s] * w * normFactor
  //
  //  where normFactor scales the source nutrient to [0,1] using
  //  reference daily values so different units are comparable.
  //
  //  Final score:
  //    effectiveContrib = directContrib + Σ Δscore(s→t)
  //                       clamped to [0, ∞)  (can't go negative
  //                       — a food can at most contribute 0 to a
  //                       parameter, not subtract from the body)

  static double propagatedScore({
    required String targetNutrient,
    required Map<String, double> foodNutrients,
    // Reference daily values for normalisation (per 100 g portion)
    Map<String, double>? referenceValues,
  }) {
    final ref = referenceValues ?? _defaultReference;

    // Direct contribution (e.g. iron in food → iron parameter)
    final direct = (foodNutrients[targetNutrient] ?? 0.0) /
        (ref[targetNutrient] ?? 1.0);

    // Indirect contributions via graph edges
    double indirect = 0.0;
    for (final edge in edgesFor(targetNutrient)) {
      final sourceAmount = foodNutrients[edge.source] ?? 0.0;
      final sourceRef    = ref[edge.source] ?? 1.0;
      indirect += (sourceAmount / sourceRef) * edge.weight;
    }

    // Total effective contribution, floored at 0
    return (direct + indirect).clamp(0.0, double.infinity);
  }

  // Default reference values (approximate daily amounts per 100 g serving, used for normalisation only) 
  static const Map<String, double> _defaultReference = {
    'iron':      2.5,   // mg   (~18 mg/day ÷ ~7 servings)
    'calcium':   150.0, // mg   (~1000 mg/day ÷ ~7)
    'vitaminC':  12.0,  // mg   (~80 mg/day ÷ ~7)
    'vitaminD':  1.0,   // µg   (~15 µg/day ÷ ~15)
    'omega3':    50.0,  // mg   (~350 mg/day ÷ ~7)
    'fiber':     3.5,   // g    (~25 g/day ÷ ~7)
    'phytates':  50.0,  // mg
    'oxalates':  20.0,  // mg
    'glucose':   1.0,
    'cholesterol': 1.0,
    'proteins':  4.0,   // g
    'carbs':     15.0,  // g
    'fats':      3.0,   // g
  };
}