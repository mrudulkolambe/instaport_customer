import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/screens/faq.dart';
import 'package:instaport_customer/screens/new_order.dart';
import 'package:instaport_customer/screens/past_orders.dart';
import 'package:instaport_customer/screens/home.dart';
import 'package:instaport_customer/screens/profile.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () => Get.to(() => const Home()),
              icon: SvgPicture.string(
                '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <path d="M22 12.2039V13.725C22 17.6258 22 19.5763 20.8284 20.7881C19.6569 22 17.7712 22 14 22H10C6.22876 22 4.34315 22 3.17157 20.7881C2 19.5763 2 17.6258 2 13.725V12.2039C2 9.91549 2 8.77128 2.5192 7.82274C3.0384 6.87421 3.98695 6.28551 5.88403 5.10813L7.88403 3.86687C9.88939 2.62229 10.8921 2 12 2C13.1079 2 14.1106 2.62229 16.116 3.86687L18.116 5.10812C20.0131 6.28551 20.9616 6.87421 21.4808 7.82274" stroke="#1C274C" stroke-width="2.4" stroke-linecap="round"></path> <path d="M15 18H9" stroke="#1C274C" stroke-width="2.4" stroke-linecap="round"></path> </g></svg>',
                height: 25,
                width: 25,
              ),
            ),
            IconButton(
              onPressed: () => Get.to(() => const Neworder()),
              icon: SvgPicture.string(
                '<?xml version="1.0" encoding="UTF-8"?><svg width="800px" height="800px" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><g data-name="add"><g fill="none" stroke="#000" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"><line x1="12" x2="12" y1="19" y2="5"/><line x1="5" x2="19" y1="12" y2="12"/></g></g></svg>',
                height: 30,
                width: 30,
              ),
            ),
            IconButton(
              onPressed: () => Get.to(() => const PastOrders()),
              icon: Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.all(Radius.circular(25))
                ),
                child: Center(
                  child: SvgPicture.string(
                    '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <path d="M21.9844 10C21.9473 8.68893 21.8226 7.85305 21.4026 7.13974C20.8052 6.12523 19.7294 5.56066 17.5777 4.43152L15.5777 3.38197C13.8221 2.46066 12.9443 2 12 2C11.0557 2 10.1779 2.46066 8.42229 3.38197L6.42229 4.43152C4.27063 5.56066 3.19479 6.12523 2.5974 7.13974C2 8.15425 2 9.41667 2 11.9415V12.0585C2 14.5833 2 15.8458 2.5974 16.8603C3.19479 17.8748 4.27063 18.4393 6.42229 19.5685L8.42229 20.618C10.1779 21.5393 11.0557 22 12 22C12.9443 22 13.8221 21.5393 15.5777 20.618L17.5777 19.5685C19.7294 18.4393 20.8052 17.8748 21.4026 16.8603C21.8226 16.1469 21.9473 15.3111 21.9844 14" stroke="#000000" stroke-width="1.9200000000000004" stroke-linecap="round"></path> <path d="M21 7.5L17 9.5M12 12L3 7.5M12 12V21.5M12 12C12 12 14.7426 10.6287 16.5 9.75C16.6953 9.65237 17 9.5 17 9.5M17 9.5V13M17 9.5L7.5 4.5" stroke="#000000" stroke-width="1.9200000000000004" stroke-linecap="round"></path> </g></svg>',
                    height: 28,
                    width: 28,
                  ),
                ),
              ),
              enableFeedback: false,
            ),
            IconButton(
              onPressed: () => Get.to(() => const FAQ()),
              icon: SvgPicture.string(
                '<?xml version="1.0" encoding="UTF-8"?><svg transform="matrix(1 0 0 1 0 0)" width="800px" height="800px" fill="none" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><g stroke="#000" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.64"><path d="m17 3.3378c-1.4709-0.85085-3.1786-1.3378-5-1.3378-5.5228 0-10 4.4772-10 10 0 1.5997 0.37562 3.1116 1.0435 4.4525 0.17748 0.3563 0.23655 0.7636 0.13366 1.1481l-0.59561 2.2261c-0.25856 0.9663 0.6255 1.8503 1.5918 1.5918l2.226-0.5956c0.38454-0.1029 0.79182-0.0438 1.1481 0.1336 1.3408 0.6679 2.8528 1.0435 4.4525 1.0435 5.5228 0 10-4.4772 10-10 0-1.8214-0.487-3.5291-1.3378-5" stroke="#1C274C" stroke-linecap="round" stroke-width="1.5"/></g><path d="m17 3.3378c-1.4709-0.85085-3.1786-1.3378-5-1.3378-5.5228 0-10 4.4772-10 10 0 1.5997 0.37562 3.1116 1.0435 4.4525 0.17748 0.3563 0.23655 0.7636 0.13366 1.1481l-0.59561 2.2261c-0.25856 0.9663 0.6255 1.8503 1.5918 1.5918l2.226-0.5956c0.38454-0.1029 0.79182-0.0438 1.1481 0.1336 1.3408 0.6679 2.8528 1.0435 4.4525 1.0435 5.5228 0 10-4.4772 10-10 0-1.8214-0.487-3.5291-1.3378-5" stroke="#1C274C" stroke-linecap="round" stroke-width="2.4"/></svg>',
                height: 25,
                width: 25,
              ),
            ),
            IconButton(
              onPressed: () => Get.to(() => const Profile()),
              icon: SvgPicture.string(
                '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <circle cx="12" cy="6" r="4" stroke="#1C274C" stroke-width="2.4"></circle> <path d="M19.9975 18C20 17.8358 20 17.669 20 17.5C20 15.0147 16.4183 13 12 13C7.58172 13 4 15.0147 4 17.5C4 19.9853 4 22 12 22C14.231 22 15.8398 21.8433 17 21.5634" stroke="#1C274C" stroke-width="2.4" stroke-linecap="round"></path> </g></svg>',
                height: 25,
                width: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
