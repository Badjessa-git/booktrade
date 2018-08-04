class Tools {

  static String convertToEdition(int editionValue) {
    final int  mod = editionValue % 10;
    switch(mod) {
      case 1:
        if (editionValue == 11) {
          return editionValue.toString()+'th';
        }
        return editionValue.toString()+'st';
        break;
      case 2:
        if (editionValue == 12) {
          return editionValue.toString()+'th'; 
        }
        return editionValue.toString()+'nd';
        break;
      case 3:
        if (editionValue == 13) {
          return editionValue.toString()+'th';
        }
        return editionValue.toString()+'rd';
        break;
      default:
        return editionValue.toString()+'th';
  }
  }
}