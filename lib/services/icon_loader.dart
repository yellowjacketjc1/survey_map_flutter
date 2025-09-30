import '../models/annotation_models.dart';

class IconLoader {
  static List<IconMetadata> loadEmbeddedIcons() {
    final icons = <IconMetadata>[];

    // Embedded drum/container icon
    icons.add(IconMetadata(
      file: 'drum-can-2-svgrepo-com.svg',
      name: 'Waste Container',
      category: IconCategory.equipment,
      keywords: ['equipment', 'container', 'drum', 'waste'],
      svgText: '''<svg version="1.1" id="_x32_" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
                width="800px" height="800px" viewBox="0 0 512 512"  xml:space="preserve">
                <style type="text/css">
                <![CDATA[
                    .st0{fill:#000000;}
                ]]>
                </style>
                <g>
                    <path class="st0" d="M191.266,42c-18.859,0-34.141,4.828-34.141,10.781c0,5.969,15.281,10.781,34.141,10.781
                        c18.844,0,34.141-4.813,34.141-10.781C225.406,46.828,210.109,42,191.266,42z"/>
                    <path class="st0" d="M434.906,189.5c0-6.313-3.344-12.406-9.422-18.094V74.594c6.078-5.688,9.422-11.781,9.422-18.094
                        C434.906,25.281,354.797,0,256,0S77.094,25.281,77.094,56.5c0,6.313,3.344,12.406,9.422,18.094v88.125
                        c1.391,1.375,2.953,2.719,4.766,4.063c8.438,6.344,21.313,12.406,37.422,17.469c32.234,10.188,77.422,16.625,127.297,16.594
                        c47.234,0.031,90.234-5.719,122.047-15l0,0c3-0.875,6.125,0.844,7,3.844s-0.844,6.125-3.844,7
                        C348,206.344,304.156,212.156,256,212.156c-33.375,0-64.688-2.781-91.813-7.719c-27.141-4.938-50.047-11.969-66.813-20.656
                        c-5.344-2.781-10.031-5.734-14.078-8.906c-3.969,4.672-6.203,9.563-6.203,14.625c0,6.344,3.344,12.406,9.422,18.094v86.672
                        c1.391,1.359,2.953,2.703,4.766,4.047c8.438,6.344,21.313,12.391,37.422,17.469c32.234,10.188,77.422,16.625,127.297,16.594
                        c47.234,0.031,90.234-5.719,122.047-15c3-0.875,6.125,0.844,7,3.844s-0.844,6.125-3.844,7C348,337.875,304.156,343.688,256,343.688
                        c-33.375,0-64.688-2.813-91.813-7.719c-27.141-4.938-50.047-11.938-66.813-20.656c-5-2.594-9.375-5.391-13.25-8.328
                        c-4.484,4.953-7.031,10.141-7.031,15.516c0,6.313,3.344,12.406,9.422,18.094v85.188c1.391,1.375,2.953,2.719,4.766,4.078
                        c8.438,6.328,21.313,12.375,37.422,17.453C160.938,457.5,206.125,463.938,256,463.906c47.234,0.031,90.234-5.719,122.047-15l0,0
                        c3-0.875,6.125,0.844,7,3.844s-0.844,6.125-3.844,7C348,469.406,304.156,475.219,256,475.219c-33.375,0-64.688-2.813-91.813-7.719
                        c-27.141-4.938-50.047-11.938-66.813-20.656c-4.656-2.438-8.75-5.031-12.438-7.75c-4.984,5.219-7.844,10.688-7.844,16.406
                        c0,31.219,80.109,56.5,178.906,56.5s178.906-25.281,178.906-56.5c0-6.313-3.344-12.391-9.422-18.078v-96.828
                        c6.078-5.688,9.422-11.75,9.422-18.094s-3.344-12.406-9.422-18.078v-96.828C431.563,201.906,434.906,195.844,434.906,189.5z
                         M256,91.813c-99.25,0-151.625-24.625-157.484-35.313C104.375,45.813,156.75,21.188,256,21.188S407.625,45.813,413.484,56.5
                        C407.625,67.188,355.25,91.813,256,91.813z"/>
                </g>
            </svg>''',
    ));

    // Embedded contamination area posting
    icons.add(IconMetadata(
      file: 'contamination-area-posting.svg',
      name: 'Contamination Area',
      category: IconCategory.contamination,
      keywords: ['contamination', 'area', 'posting', 'radiological'],
      svgText: '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 400" width="300" height="400">
                <!-- Yellow background -->
                <rect width="300" height="400" fill="#FFFF00" stroke="#000000" stroke-width="4"/>

                <!-- Header section with magenta stripe -->
                <rect x="10" y="10" width="280" height="60" fill="#FF00FF"/>
                <text x="150" y="30" text-anchor="middle" fill="black" font-family="Arial, sans-serif" font-size="14" font-weight="bold">CAUTION</text>
                <text x="150" y="50" text-anchor="middle" fill="black" font-family="Arial, sans-serif" font-size="14" font-weight="bold">CONTAMINATION AREA</text>

                <!-- Main trefoil symbol (radiation symbol) -->
                <g transform="translate(150, 180)">
                    <!-- Central circle -->
                    <circle cx="0" cy="0" r="15" fill="black"/>

                    <!-- Three radiation blades -->
                    <g>
                        <!-- Blade 1 (top) -->
                        <path d="M 0,-15 L -25,-60 A 25,25 0 0,1 25,-60 Z" fill="black"/>
                        <!-- Blade 2 (bottom right) -->
                        <g transform="rotate(120)">
                            <path d="M 0,-15 L -25,-60 A 25,25 0 0,1 25,-60 Z" fill="black"/>
                        </g>
                        <!-- Blade 3 (bottom left) -->
                        <g transform="rotate(240)">
                            <path d="M 0,-15 L -25,-60 A 25,25 0 0,1 25,-60 Z" fill="black"/>
                        </g>
                    </g>

                    <!-- Yellow and black striped inner sections -->
                    <g>
                        <!-- Inner section 1 -->
                        <path d="M 0,-15 L -15,-35 A 15,15 0 0,1 15,-35 Z" fill="#FFFF00"/>
                        <!-- Inner section 2 -->
                        <g transform="rotate(120)">
                            <path d="M 0,-15 L -15,-35 A 15,15 0 0,1 15,-35 Z" fill="#FFFF00"/>
                        </g>
                        <!-- Inner section 3 -->
                        <g transform="rotate(240)">
                            <path d="M 0,-15 L -15,-35 A 15,15 0 0,1 15,-35 Z" fill="#FFFF00"/>
                        </g>
                    </g>
                </g>

                <!-- Warning text -->
                <text x="150" y="280" text-anchor="middle" fill="black" font-family="Arial, sans-serif" font-size="12" font-weight="bold">AUTHORIZED PERSONNEL ONLY</text>
                <text x="150" y="300" text-anchor="middle" fill="black" font-family="Arial, sans-serif" font-size="10">Any area accessible to individuals</text>
                <text x="150" y="315" text-anchor="middle" fill="black" font-family="Arial, sans-serif" font-size="10">where radioactive materials exist</text>
                <text x="150" y="330" text-anchor="middle" fill="black" font-family="Arial, sans-serif" font-size="10">in concentrations which result in</text>
                <text x="150" y="345" text-anchor="middle" fill="black" font-family="Arial, sans-serif" font-size="10">the major portion of the body</text>
                <text x="150" y="360" text-anchor="middle" fill="black" font-family="Arial, sans-serif" font-size="10">receiving more than 5 millirem</text>
                <text x="150" y="375" text-anchor="middle" fill="black" font-family="Arial, sans-serif" font-size="10">in any one hour, or 100 millirem</text>
                <text x="150" y="390" text-anchor="middle" fill="black" font-family="Arial, sans-serif" font-size="10">in any 5 consecutive days.</text>
            </svg>''',
    ));

    return icons;
  }
}
