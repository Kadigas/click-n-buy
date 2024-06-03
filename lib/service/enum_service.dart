import 'package:fp_ppb/enums/product_category.dart';
import 'package:fp_ppb/enums/product_condition.dart';

class EnumService {
  ProductCategory parseProductCategory(String condition) {
    switch (condition) {
      case 'electronics':
        return ProductCategory.electronics;
      case 'fashion':
        return ProductCategory.fashion;
      case 'home':
        return ProductCategory.home;
      case 'beauty':
        return ProductCategory.beauty;
      case 'sports':
        return ProductCategory.sports;
      case 'toys':
        return ProductCategory.toys;
      default:
        return ProductCategory.electronics;
    }
  }

  ProductCondition parseProductCondition(String condition) {
    switch (condition) {
      case 'brandNew':
        return ProductCondition.brandNew;
      case 'used':
        return ProductCondition.used;
      case 'refurbished':
        return ProductCondition.refurbished;
      default:
        return ProductCondition.brandNew;
    }
  }

}