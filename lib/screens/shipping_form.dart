import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/components/appbar.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/controllers/order.dart';
import 'package:instaport_customer/screens/payment.dart';

class ShippingForm extends StatefulWidget {
  const ShippingForm({super.key});

  @override
  State<ShippingForm> createState() => _ShippingFormState();
}

class _ShippingFormState extends State<ShippingForm> {
  OrderController orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: CustomAppBar(
          title: "Shipping Details",
          back: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: GetBuilder<OrderController>(
            init: OrderController(),
            builder: (ordercontroller) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          "Select shipping:",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () => orderController.updateVehicle("bike"),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color:
                                orderController.currentorder.vehicle == "bike"
                                    ? accentColor
                                    : Colors.black12,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4F000000),
                              blurRadius: 18,
                              offset: Offset(2, 4),
                              spreadRadius: -15,
                            )
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.20),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                        child: SvgPicture.string(
                                          '<?xml version="1.0" encoding="UTF-8"?><svg fill="none" viewBox="0 0 24 17" xmlns="http://www.w3.org/2000/svg"><g clip-path="url(#a)"><path d="m9.9023 7.5433-0.03125-0.13976c-0.46679 0.1336-0.93554 0.17676-1.4082 0.16032-0.53906-0.0185-1.0781-0.1151-1.6172-0.24459-0.26367-0.06372-0.49414-0.13155-0.71289-0.19732-0.49219-0.14593-0.92578-0.27336-1.5234-0.27953h-0.01563l-2.1621-0.1932-0.42578 0.64538c1.2422 0.50563 2.7852 0.85915 4.2695 0.99686 1.4004 0.12949 2.7422 0.06988 3.7207-0.23431l-0.09375-0.51385zm10.537 1.9649c1.9667 0 3.5605 1.6772 3.5605 3.747 0 2.0697-1.5938 3.7469-3.5605 3.7469-1.9668 0-3.5606-1.6772-3.5606-3.7469 0-1.2497 0.5801-2.3555 1.4727-3.0358l-1.0332-2.1376-1.8965 6.0017h-0.8379c0 0.0247 0 0.0493-0.0039 0.0719-0.0703 0.407-0.1895 0.7359-0.3574 0.9825-0.1875 0.2754-0.4317 0.4522-0.7344 0.5282-0.3692 0.0925-1.4043-0.0822-2.0801-0.1952-0.1797-0.0308-0.334-0.0555-0.4336-0.0699l-2.2285-0.3145-0.00976 0.037c-0.05274 0.222-0.25781 0.3679-0.47656 0.3309l-1.3828-0.2384c-0.14843 0.2467-0.32422 0.4728-0.52148 0.6762-0.6543 0.6742-1.5606 1.0914-2.5586 1.0914-0.99805 0-1.9024-0.4172-2.5586-1.0914-0.65625-0.6762-1.0625-1.6093-1.0625-2.6391 0-1.0297 0.40625-1.9629 1.0625-2.6391 0.6543-0.67413 1.5606-1.0914 2.5586-1.0914 0.99804 0 1.9023 0.41724 2.5586 1.0914 0.65625 0.6762 1.0625 1.6094 1.0625 2.6391 0 0.1151-0.00586 0.2282-0.01563 0.3392l1.2051 0.3514c0.20703 0.0596 0.33594 0.2755 0.30469 0.4933l2.1426 0.3022c0.1113 0.0164 0.2676 0.0411 0.4512 0.0719 0.625 0.1048 1.5839 0.2652 1.8359 0.2035 0.1484-0.037 0.2695-0.1274 0.3652-0.2672 0.1094-0.1603 0.1895-0.3844 0.2422-0.668h-5.0879c-1.5469-5.5454-5.4141-6.3059-7.6328-4.3204l-1.2285-0.01645c0.36719-0.93725 1.2305-1.5456 2.2793-1.8724-0.23242-0.08427-0.45508-0.17265-0.66992-0.2672-0.01758-0.00617-0.03321-0.01439-0.04883-0.02672-0.09571-0.06988-0.11914-0.20759-0.05274-0.30831l0.64258-0.97424c0.04102-0.06578 0.11523-0.10688 0.19531-0.10072l2.2832 0.20348c0.65039 0.01028 1.1035 0.14388 1.6191 0.29598 0.21484 0.06371 0.4414 0.12949 0.69336 0.19115 0.51562 0.12538 1.0293 0.21787 1.5352 0.23431 0.48633 0.01644 0.97071-0.03494 1.4492-0.19732 0.15622-0.14593 0.31442-0.28569 0.47852-0.41929 0.1699-0.13977 0.3496-0.27542 0.541-0.40902 0.5098-0.35764 1.0332-0.64333 1.586-0.83859 0.5566-0.19526 1.1406-0.29803 1.7714-0.2857 0.3887 0.00822 0.7657 0.06988 1.1231 0.19937 0.2461 0.09044 0.4844 0.2117 0.7109 0.36791 2e-3 -0.04111 0.0156-0.08221 0.0391-0.1151l-1.127-0.88998h-1.7617c-0.2051 0-0.3691-0.1747-0.3691-0.38846 0-0.21582 0.166-0.38847 0.3691-0.38847h1.6231v-1.5498h0.0019v-0.00822c2e-3 -0.05138 0-0.09866-0.0059-0.13977-0.0039-0.03494-0.0117-0.06782-0.0214-0.10071-0.0313-0.10071-0.0977-0.14388-0.1875-0.20143-0.0059-0.00205-0.0098-0.00616-0.0157-0.00822-0.0097-0.00616-0.0195-0.01233-0.0429-0.02672l-0.0157 0.2672c-0.0097 0.15827-0.1386 0.27953-0.291 0.26926-0.1504-0.01028-0.2656-0.14594-0.2558-0.30626l0.1015-1.6833c0.0098-0.15826 0.1387-0.27953 0.2911-0.26925 0.1503 0.010277 0.2656 0.14593 0.2558 0.30625l-0.0469 0.76665 0.2051 0.13155 0.0762 0.04727c0.0058 0.00206 0.0098 0.00617 0.0137 0.01028 0.1953 0.11921 0.3378 0.21376 0.4335 0.52001 0.0196 0.06166 0.0333 0.12949 0.043 0.20554 0.0078 0.06782 0.0117 0.14182 0.0098 0.21992v1.6834l0.7148 0.56318 0.0645-0.07811-0.168-0.12743c-0.0937-0.07194-0.1152-0.21171-0.0469-0.31036 0.0059-0.00823 0.0118-0.01645 0.0176-0.02261l0.6582-0.80776c0.0762-0.0925 0.209-0.10483 0.2969-0.02467l0.0039 0.00411 0.6152 0.53234c0.0899 0.07811 0.1036 0.21787 0.0293 0.31242l-0.0039 0.00617-0.6426 0.77076c-0.0253 0.03083-0.0566 0.05139-0.0898 0.06372l-0.2285 0.08221 0.209 0.16443 0.0058 0.00617 0.0625-0.03289c0.1035-0.05344 0.2305-0.00822 0.2832 0.10072l0.0039 0.00616 0.3008 0.60428c0.1446-0.34119 0.4668-0.5755 0.7481-0.78104 0.0586-0.04316 0.1172-0.08633 0.1679-0.12538 0.2207-0.17265 0.4258-0.28364 0.6114-0.33297 0.205-0.05549 0.3906-0.03905 0.5488 0.04316 0.1582 0.08428 0.2812 0.23021 0.3613 0.4378 0.0723 0.18704 0.1114 0.42341 0.1114 0.70705v0.81804c0 0.01027 0 0.02261-2e-3 0.03288-0.0215 0.36175-0.0996 0.62278-0.2227 0.79954-0.0761 0.10894-0.166 0.18499-0.2695 0.23432s-0.2148 0.06782-0.332 0.06166c-0.252-0.01439-0.5352-0.1521-0.8281-0.38025l-0.2247-0.1747 1.3262 2.5857c0.2852-0.07605 0.5879-0.11716 0.8985-0.11716zm-1.7266 0.46863c0.1348-0.08016 0.2754-0.15005 0.4219-0.20965l-2.1524-4.2382c-0.0058 0.01027-0.0117 0.02055-0.0195 0.03083-0.0879 0.05755-0.1973 0.12949-0.3027 0.15415l2.0527 4.2628zm-16.205 2.1951 0.88281 0.2569c0.06446-0.0329 0.13086-0.0575 0.20313-0.074l0.05469-1.4798h-0.00977l-0.01758 2e-3c-0.01562 0.0021-0.03125 0.0021-0.04687 0.0041h-0.00781c-0.01758 0.0021-0.03321 0.0041-0.05079 0.0062l-0.01757 0.0021c-0.01172 2e-3 -0.02344 0.0041-0.03321 0.0041l-0.01953 0.0041c-0.01172 2e-3 -0.02344 0.0041-0.0332 0.0061l-0.01758 0.0042c-0.01367 2e-3 -0.02734 0.0061-0.04101 0.0082l-0.00977 2e-3c-0.01758 0.0041-0.0332 0.0082-0.05078 0.0124l-0.01563 0.0041c-0.01171 2e-3 -0.02343 0.0061-0.03515 0.0082l-0.01953 0.0062-0.03321 0.0102-0.01757 0.0041c-0.01368 0.0042-0.02735 0.0083-0.03907 0.0124l-0.00976 2e-3c-0.01563 0.0062-0.03125 0.0103-0.04688 0.0165l-0.01758 0.0061c-0.00976 0.0042-0.02148 0.0083-0.03125 0.0124l-0.01953 0.0082-0.02929 0.0123-0.01954 0.0083c-0.00976 0.0041-0.01953 0.0082-0.02929 0.0123l-0.01758 0.0082c-0.01367 0.0062-0.0293 0.0123-0.04297 0.0206l-0.01758 0.0082-0.02734 0.0144-0.02149 0.0102-0.02343 0.0124-0.02149 0.0123-0.02343 0.0082-0.01954 0.0103h-0.00195c-0.01367 0.0082-0.02539 0.0144-0.03906 0.0226l-0.02344 0.0144-0.01758 0.0103c-0.00781 0.0041-0.01562 0.0103-0.02343 0.0164l-0.01758 0.0124-0.04102 0.0287-0.02539 0.0165-0.00586 0.0041c-0.01953 0.0144-0.03906 0.0288-0.05859 0.0431l-0.01172 0.0083-0.02539 0.0205-0.01367 0.0124c-0.00782 0.0061-0.01563 0.0123-0.02344 0.0205l-0.01172 0.0103c-0.0293 0.0247-0.05859 0.0514-0.08789 0.0781l-0.00586 0.0041c-0.00781 0.0082-0.01758 0.0164-0.02539 0.0247l-0.00977 0.0102c-0.00781 0.0083-0.01562 0.0165-0.02539 0.0247l-0.00976 0.0103c-0.00782 0.0082-0.01563 0.0164-0.02344 0.0246l-0.00391 0.0042c-0.02929 0.0308-0.05664 0.0616-0.08203 0.0925l-0.00586 0.0061c-0.00781 0.0103-0.01562 0.0206-0.02539 0.0308l-0.00195 0.0062c-0.0293 0.035-0.05664 0.072-0.08398 0.111l0.52343 0.3453zm2.3867 0.6947 1.1719 0.3412c-0.00586-0.3145-0.07032-0.6166-0.18164-0.89l-0.99024 0.5488zm0.49024 2.0944-1.418-0.2445-0.02149 0.9208 0.02344-0.0021h0.00977c0.01757-2e-3 0.0332-2e-3 0.05078-0.0041l0.01172-0.0021c0.01562-2e-3 0.02929-0.0041 0.04492-0.0061h0.00781c0.01563-0.0021 0.03125-0.0041 0.04687-0.0062l0.01563-2e-3c0.01563-0.0021 0.03125-0.0062 0.04883-0.0083h0.00195c0.01563-2e-3 0.03125-0.0061 0.04688-0.0102l0.01171-0.0021c0.01563-0.0041 0.03126-0.0062 0.04688-0.0103l0.00781-2e-3c0.01367-0.0041 0.02735-0.0062 0.04102-0.0103l0.01172-0.0041c0.01562-0.0041 0.03125-0.0082 0.04492-0.0123l0.01172-0.0042c0.01367-0.0041 0.02929-0.0082 0.04297-0.0143l0.0039-0.0021h0.00196c0.01367-0.0041 0.02929-0.0103 0.04296-0.0144l0.01563-0.0062c0.01367-0.0041 0.02734-0.0102 0.04101-0.0164l0.01172-0.0041c0.01172-0.0041 0.02149-0.0082 0.03321-0.0144l0.01562-0.0062c0.01367-0.0061 0.02539-0.0102 0.03906-0.0164l0.01758-0.0082 0.02735-0.0124 0.01562-0.0082c0.01172-0.0061 0.02344-0.0123 0.03516-0.0185l0.02148-0.0103 0.02344-0.0123c0.00976-0.0062 0.01953-0.0103 0.0293-0.0164l0.02148-0.0124 0.02148-0.0123c0.00977-0.0062 0.01954-0.0103 0.0293-0.0164 0.00781-0.0041 0.01563-0.0103 0.02539-0.0144l0.01953-0.0124 0.02149-0.0143c0.00976-0.0062 0.01953-0.0124 0.02929-0.0185l0.02344-0.0165 0.01367-0.0082c0.01368-0.0103 0.02735-0.0185 0.03907-0.0288l0.00781-0.0062 0.02344-0.0184 0.00976-0.0062c0.01563-0.0123 0.0293-0.0226 0.04492-0.035l0.00586-0.0061c0.00782-0.0062 0.01563-0.0144 0.02539-0.0206l0.00391-2e-3c0.01563-0.0124 0.03125-0.0268 0.04688-0.0391l0.00976-0.0082c0.02539-0.0226 0.04883-0.0452 0.07227-0.0678 0.01367-0.0144 0.02734-0.0288 0.04297-0.0453zm-1.8379-0.3165-1.3438-0.2322-0.29101 0.1664 0.00195 0.0042c0.00586 0.0082 0.01172 0.0164 0.01758 0.0267l0.01172 0.0185 0.01758 0.0246 0.01172 0.0185c0.00586 0.0083 0.01171 0.0165 0.01757 0.0247l0.01172 0.0164 0.01758 0.0247 0.01367 0.0165c0.00586 0.0082 0.01172 0.0164 0.01953 0.0246 0.00586 0.0062 0.00977 0.0124 0.01563 0.0206 0.00586 0.0061 0.00976 0.0123 0.01562 0.0205 0.00977 0.0124 0.02149 0.0247 0.03125 0.037l0.01954 0.0226 0.01562 0.0165c0.00586 0.0061 0.01172 0.0123 0.01758 0.0205l0.01758 0.0206 0.01757 0.0164 0.01954 0.0206 0.01757 0.0185 0.01758 0.0185 0.01953 0.0185 0.01758 0.0164 0.01953 0.0165 0.02149 0.0185c0.00586 0.0061 0.01172 0.0102 0.01758 0.0164 0.01171 0.0103 0.02539 0.0206 0.0371 0.0308l0.01563 0.0124c0.00781 0.0061 0.01563 0.0123 0.02539 0.0205l0.01953 0.0165 0.01953 0.0164 0.02149 0.0164 0.02148 0.0165 0.02149 0.0164 0.04296 0.0288c0.00782 0.0062 0.01563 0.0103 0.02344 0.0165l0.01953 0.0123c0.00977 0.0062 0.01953 0.0123 0.0293 0.0185l0.01563 0.0103c0.01562 0.0082 0.02929 0.0185 0.04492 0.0267l0.01562 0.0082c0.00977 0.0062 0.01953 0.0123 0.03125 0.0164l0.01953 0.0103 0.02735 0.0144 0.01953 0.0103 0.02734 0.0144 0.02149 0.0103c0.00976 0.0041 0.01757 0.0082 0.02734 0.0123l0.01953 0.0082c0.00977 0.0041 0.02149 0.0082 0.03125 0.0144l0.01758 0.0082c0.01367 0.0062 0.0293 0.0123 0.04297 0.0165l0.00586 2e-3h0.00195c0.01563 0.0062 0.03125 0.0123 0.04883 0.0185l0.01562 0.0062c0.01172 0.0041 0.02149 0.0082 0.03321 0.0123l0.01758 0.0062c0.01171 0.0041 0.02343 0.0061 0.0332 0.0103l0.01758 0.0061 0.03125 0.0082 0.02148 0.0062c0.01172 0.0021 0.02344 0.0062 0.0332 0.0082l0.01758 0.0041c0.01172 0.0021 0.02344 0.0062 0.03711 0.0083l0.01758 0.0041c0.01563 0.0041 0.0293 0.0061 0.04492 0.0082l0.00586 2e-3c0.01758 0.0042 0.03516 0.0062 0.05078 0.0083l0.02149 0.0041c0.00976 2e-3 0.02148 0.0041 0.03125 0.0041l0.02148 2e-3 0.02735-0.9845zm-1.4004-2.117-0.50586-0.0103-0.44921-0.0082-0.20118 0.7893 0.78321 0.5919 1.9062 0.3289 0.29883 0.0513 1.3613 0.2344 0.35547 0.0616 1.3984 0.2405 1.2012 0.2076c0.06055-0.1069 0.1582-0.5324 0.20313-0.631l0.00195-0.0082-1.5293-0.444-0.93554-0.2713-3.0234-0.8776-0.67578-0.1974-0.18946-0.0575zm16.422-7.1836c-0.252 0.18499-0.5469 0.39875-0.6016 0.63922-0.0254 0.11099-0.0313 0.16854-0.0156 0.19732 0.0176 0.037 0.08 0.08633 0.1758 0.16032l0.5976 0.46246c0.2188 0.16854 0.416 0.27131 0.5664 0.28159 0.041 0.00205 0.0762-0.00206 0.1055-0.01645 0.0273-0.01233 0.0527-0.03699 0.0762-0.06988 0.0683-0.09866 0.1152-0.26926 0.1289-0.52618v-0.82009c0-0.21993-0.0254-0.39052-0.0723-0.51179-0.0332-0.08633-0.0781-0.14387-0.1289-0.1706-0.0508-0.02672-0.1211-0.02877-0.209-0.00616-0.125 0.03288-0.2734 0.1151-0.4414 0.24664-0.0566 0.04317-0.1172 0.08633-0.1816 0.1336zm-2.4434 1.2332-0.0215-0.5159c-0.2539-0.21376-0.5273-0.36791-0.8164-0.47068-0.3184-0.1151-0.6504-0.1706-0.9941-0.17676-0.5801-0.01234-1.1192 0.08221-1.6309 0.26308-0.5156 0.18088-1.0059 0.45013-1.4844 0.78721-0.1738 0.12127-0.3457 0.25281-0.5156 0.39258-0.1367 0.11099-0.2676 0.22403-0.3926 0.34119l0.043 0.23431 0.127 0.56318 4.8359 0.01849h0.0195c0.1289 0.01234 0.2403 0.00412 0.336-0.02261 0.0859-0.02672 0.1601-0.06988 0.2207-0.12743 0.3125-0.30008 0.2929-0.81393 0.2754-1.262l-2e-3 -0.02466zm-7.1875 2.9166 1.8574-0.02672c0.1348-0.00205 0.2617 0.11921 0.2461 0.25898l-0.1387 1.26c-0.0156 0.1418-0.1113 0.2589-0.2461 0.2589h-1.1738c-0.13476 0-0.18945-0.1295-0.24609-0.2589l-0.54688-1.2333c-0.05664-0.12949 0.11133-0.25692 0.24805-0.25898zm4.3555-0.15621h1.6797c0.1347 0 0.2773 0.12127 0.2461 0.25898l-0.3555 1.5909c-0.0313 0.1377-0.1113 0.259-0.2461 0.259h-1.1738c-0.1348 0-0.2325-0.1172-0.2461-0.259l-0.1524-1.5909c-0.0117-0.14182 0.1133-0.25898 0.2481-0.25898zm-7.6094 2.5898c-0.35937-0.5632-0.9414-0.9557-1.6133-1.04l-0.05273 1.4778c0.1582 0.0432 0.29883 0.1295 0.41015 0.2467l0.00782 0.0082 1.248-0.6927zm-3.3438 3.155c0.00586 0.0062 0.01172 0.0103 0.01758 0.0165l-0.01758-0.0165zm17.994-2.748 0.0547-1.5004c-0.709 0.0164-1.3379 0.3699-1.75 0.9146l1.2597 0.8345c0.1172-0.1233 0.2676-0.2097 0.4356-0.2487zm0.4746-1.4717-0.0527 1.4799c0.1562 0.0432 0.2988 0.1295 0.4101 0.2466l0.0078 0.0083 1.1953-0.6639c-0.3457-0.5591-0.9062-0.9599-1.5605-1.0709zm1.7578 1.4655-1.1758 0.6536c0.0254 0.0884 0.041 0.183 0.041 0.2796 0 0.0863-0.0097 0.1685-0.0312 0.2466l1.1328 0.7502c0.1328-0.3062 0.207-0.6474 0.207-1.0051 0-0.3268-0.0605-0.6392-0.1738-0.9249zm-0.2441 2.3164-1.125-0.7461c-0.0098 0.0124-0.0215 0.0226-0.0313 0.035-0.1211 0.1274-0.2734 0.2178-0.4453 0.2569l-0.0352 1.4696c0.6758-0.074 1.2657-0.4584 1.6368-1.0154zm-2.0586 1.0215 0.0351-1.486c-0.1562-0.0432-0.2968-0.1295-0.4082-0.2466-0.0156-0.0185-0.0332-0.035-0.0468-0.0535l-1.2989 0.7441c0.3809 0.5858 1.0039 0.9865 1.7188 1.042zm-1.9258-1.4305 1.3125-0.7523c-0.0156-0.0719-0.0254-0.1459-0.0254-0.2219 0-0.1069 0.0176-0.2097 0.0469-0.3042l-1.2657-0.8386c-0.1718 0.3391-0.2675 0.7235-0.2675 1.1345 0.0019 0.3494 0.0722 0.6824 0.1992 0.9825zm2.5527-1.3565c-0.0918-0.0966-0.2207-0.1563-0.3633-0.1563-0.1425 0-0.2695 0.0597-0.3632 0.1583-0.0235 0.0247-0.045 0.0514-0.0625 0.0802-2e-3 0.0041-0.0039 0.0082-0.0078 0.0123-2e-3 0.0041-0.0059 0.0082-0.0079 0.0123-0.0449 0.0802-0.0703 0.1747-0.0703 0.2734 0 0.15 0.0567 0.2836 0.1504 0.3823 0.0918 0.0966 0.2207 0.1583 0.3633 0.1583 0.1406 0 0.2695-0.0596 0.3633-0.1583 0.0273-0.0288 0.0508-0.0596 0.0703-0.0925 0.0059-0.0185 0.0137-0.037 0.0234-0.0555 0.0039-0.0082 0.0098-0.0144 0.0137-0.0205 0.0273-0.0658 0.041-0.1378 0.041-0.2138 0-0.148-0.0566-0.2816-0.1504-0.3802z" clip-rule="evenodd" fill="#FFD02E" fill-rule="evenodd"/></g><defs><clipPath id="a"><rect width="24" height="17" fill="#fff"/></clipPath></defs></svg>',
                                          height: 25,
                                          width: 25,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text(
                                            "Bike",
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            "For low capacity delivery",
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () => orderController.updateVehicle("scooty"),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color:
                                orderController.currentorder.vehicle == "scooty"
                                    ? accentColor
                                    : Colors.black12,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4F000000),
                              blurRadius: 18,
                              offset: Offset(2, 4),
                              spreadRadius: -15,
                            )
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.20),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                        child: SvgPicture.string(
                                          '<svg width="24" height="14" viewBox="0 0 24 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12.5795 0.0922966C12.2651 0.243977 12.1513 0.645257 12.3246 0.975737C12.4763 1.27382 12.6119 1.30094 13.8097 1.30094H14.8993L15.5173 2.53142L16.1353 3.76742L14.7476 6.51542L13.3599 9.26894H11.8801C10.5035 9.26894 10.4003 9.26342 10.4003 9.17126C10.4003 8.80814 10.6333 6.33086 10.682 6.17918C10.785 5.84846 10.9856 5.49614 11.2621 5.14934C11.414 4.95974 11.5494 4.72646 11.571 4.6235C11.6523 4.18454 11.4301 3.71822 11.0451 3.51782C10.8229 3.40406 10.7742 3.40406 7.09378 3.40406C3.40786 3.40406 3.36466 3.40406 3.14242 3.51782C2.68162 3.75638 2.4757 4.34726 2.69242 4.83494C2.8117 5.11142 3.08818 5.34998 3.34834 5.3987C3.55426 5.44214 3.51634 5.49086 3.21826 5.58302C2.8225 5.70758 2.07994 6.11966 1.7113 6.42326C1.01242 7.00334 0.649298 7.5887 0.242738 8.78654C-0.0987816 9.79478 -0.0824616 10.2013 0.307778 10.6348C0.611378 10.9708 0.844418 11.0577 1.48402 11.0577H2.03146L2.0965 11.4479C2.29714 12.6186 3.2077 13.551 4.38394 13.8004C5.86378 14.1148 7.3813 13.1771 7.77154 11.7028C7.81498 11.5401 7.8529 11.3289 7.8529 11.2312V11.0577H10.8505C12.7422 11.0577 13.9184 11.0361 14.043 11.0034C14.1567 10.971 14.3247 10.8789 14.4169 10.8028C14.5091 10.7214 15.219 9.71342 15.9887 8.55326C16.7639 7.39862 17.4035 6.45014 17.4195 6.45014C17.4519 6.45014 17.9075 7.3499 17.9562 7.5179C17.9886 7.61534 17.9507 7.68062 17.7719 7.83758C16.9967 8.5367 16.46 9.71846 16.4492 10.7483L16.4439 11.2252L16.6446 11.4148C16.9211 11.6641 17.2463 11.6749 17.5172 11.4364L17.7015 11.2737L17.7666 11.5773C17.9564 12.5421 18.7748 13.4257 19.7504 13.7238C20.222 13.8702 20.9646 13.881 21.3927 13.7509C22.4118 13.4365 23.1759 12.6397 23.4361 11.6262C23.6799 10.6669 23.3819 9.61526 22.6556 8.88902C22.3791 8.61254 22.3249 8.54198 22.4389 8.58014C22.6556 8.66702 22.9971 8.54774 23.1435 8.3363C23.3063 8.11406 23.3063 7.76726 23.1491 7.54502C22.9919 7.33358 22.2656 6.97046 21.6747 6.82406C21.2845 6.72662 21.1165 6.7103 20.5093 6.73742C20.1246 6.75374 19.7504 6.78614 19.6854 6.80246C19.5716 6.84038 19.5066 6.72662 18.6447 4.96502C17.745 3.13286 17.7234 3.08966 17.5662 3.08966C17.1272 3.08966 16.6556 2.78606 16.4442 2.3687C16.2275 1.92422 16.2762 1.2791 16.5579 0.970217C16.6338 0.888857 16.6338 0.856457 16.5471 0.693737C16.3736 0.357737 16.2383 0.205817 16.016 0.102858C15.8156 0.0106974 15.6421 -0.000103951 14.276 -0.000103951C12.986 0.000136375 12.7311 0.0164566 12.5795 0.0922966ZM21.2031 9.93566C21.6531 10.2013 21.8915 10.8191 21.729 11.3015C21.6205 11.6375 21.2737 11.9682 20.9322 12.0657C19.7017 12.4235 18.8833 10.8515 19.8697 10.0331C19.9835 9.93542 20.1515 9.83798 20.2383 9.81086C20.5203 9.72422 20.9322 9.77846 21.2031 9.93566ZM6.09682 11.2312C6.04258 11.5293 5.79322 11.8273 5.46802 11.9953C5.21866 12.1254 5.1265 12.147 4.88266 12.1199C4.36234 12.0712 3.93418 11.7025 3.8149 11.2038L3.77698 11.0574H4.95322H6.13474L6.09682 11.2312Z" fill="#FFD02E"/><path d="M17.2846 0.927046C16.6884 1.16561 16.542 1.97849 17.0244 2.42297C17.2251 2.61257 17.4202 2.65601 18.0488 2.65601H18.6396V1.76153V0.867286L18.0324 0.872806C17.6964 0.872806 17.3604 0.899926 17.2846 0.927046Z" fill="#FFD02E"/></svg>',
                                          height: 23,
                                          width: 23,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text(
                                            "Scooty",
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            "For high capacity delivery",
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const PaymentForm()),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: accentColor,
                        ),
                        child: Center(
                          child: Text(
                            "Continue",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
