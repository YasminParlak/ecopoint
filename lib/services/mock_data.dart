import '../models/collection_point.dart';
import '../core/constants/app_strings.dart';

class MockData {
  static final List<CollectionPoint> points = [
    CollectionPoint(
      id: '1',
      name: 'ЭкоПункт "Чистый Город"',
      address: 'ул. Ленина, 15, рядом с парком',
      distance: '350 м',
      wasteTypes: [AppStrings.wastePlastic, AppStrings.wasteGlass, AppStrings.wastePaper],
      isOpen: true,
      latitude: 55.751244,   // 👈 ДОБАВЬ
      longitude: 37.618423,  // 👈 ДОБАВЬ
    ),
    CollectionPoint(
      id: '2',
      name: 'Пункт приёма "Вторсырьё"',
      address: 'пр. Мира, 42, во дворе',
      distance: '1.2 км',
      wasteTypes: [AppStrings.wasteMetal, AppStrings.wasteClothes],
      isOpen: true,
      latitude: 55.755814,   // 👈 ДОБАВЬ
      longitude: 37.617635,  // 👈 ДОБАВЬ
    ),
    CollectionPoint(
      id: '3',
      name: 'Сбор опасных отходов',
      address: 'ул. Гагарина, 8, ТЦ "Зелёный"',
      distance: '2.5 км',
      wasteTypes: [AppStrings.wasteBatteries, AppStrings.wasteHazardous, AppStrings.wasteElectronics],
      isOpen: false,
      latitude: 55.749792,   // 👈 ДОБАВЬ
      longitude: 37.632505,  // 👈 ДОБАВЬ
    ),
    CollectionPoint(
      id: '4',
      name: 'Эко-контейнер у дома',
      address: 'ул. Пушкина, 10',
      distance: '150 м',
      wasteTypes: [AppStrings.wastePlastic, AppStrings.wastePaper],
      isOpen: true,
      latitude: 55.753215,   // 👈 ДОБАВЬ
      longitude: 37.622504,  // 👈 ДОБАВЬ
    ),
  ];
}