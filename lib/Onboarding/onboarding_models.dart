class OnboardingModel {
  final String imageAsset;
  final String title;
  final String description;

  OnboardingModel({this.description, this.imageAsset, this.title});
}

List<OnboardingModel> onboardong = <OnboardingModel>[
  OnboardingModel(
    description:
        '''Te mostramos los restaurantes mas cercanos para que tu comida llegue lo más rápido posible''',
    imageAsset: 'assets/images/ill1.png',
    title: 'Restaurantes cercanos',
  ),
  OnboardingModel(
    description:
        '''No salgas de casa, puedes elegir tu comida favorita con un solo clic''',
    imageAsset: 'assets/images/ill2.png',
    title: 'Pide en tu lugar favorito',
  ),
  OnboardingModel(
    description:
        '''Descubre los mejores restaurantes en San Quintín, Baja California''',
    imageAsset: 'assets/images/ill3.png',
    title: 'Solo en SQ Entregas',
  ),
];
