import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final MaskTextInputFormatter phoneNumberMask = MaskTextInputFormatter(
  mask: '+91 ##### #####',
  filter: {"#": RegExp(r'[0-9]')},
);


final MaskTextInputFormatter amountMask = MaskTextInputFormatter(
  mask: '#####',
  filter: {"#": RegExp(r'[0-9]')},
);

final MaskTextInputFormatter dateMask = MaskTextInputFormatter(
  mask: '##-##-20##',
  filter: {"#": RegExp(r'[0-9]')},
);

final MaskTextInputFormatter timeMask = MaskTextInputFormatter(
  mask: '##:##',
  filter: {"#": RegExp(r'[0-9]')},
);