// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MoodNft is ERC721, Ownable {
    using Strings for uint256;

    error ERC721Metadata__URI_QueryFor_NonExistentToken();
    error MoodNft__CantFlipMoodIfNotOwner();

    uint256 public s_tokenCounter;

    AggregatorV3Interface public priceFeed;
    string private md1 = "data:application/json;base64,";
    string private md2 = "data:image/svg+xml;base64,";

    event CreatedNFT(uint256 indexed tokenId);

    struct Feel {
        uint256 bg;
        uint256 faceClr; // same for ear
        uint256 shirtClr;
        uint256 hairclr;
        uint256 prop;
        uint256 earring;
        uint256 hairtype;
        uint256 lipsclr;
        uint256 eyesd; // eyes direction
        uint256 feel_up;
        uint256 feel_down;
    }

    string private ear1 =
        '" /> <ellipse rx="69.0731" ry="65.7308" transform="matrix(.188577 0 0 0.484658 128.565251 218.143006)" fill="';
    string private ear2 =
        '" /> <ellipse rx="69.0731" ry="65.7308" transform="matrix(.188577 0 0 0.484658 362.523 218.143)" fill="';

    string[] private pn = [
        // prop names
        "",
        "",
        "crown",
        "necklace",
        "hoodie",
        "holy",
        "hoodie",
        "pirate eye patch",
        "glasses",
        "stoned",
        "",
        "taped mouth",
        "sewed mouth",
        "always angry mouth",
        "star",
        "triangle",
        "circle",
        "",
        ""
    ];

    string[] private feelsDownTraitNames = [
        // _feels bad
        "rekt",
        "lost",
        "down",
        "fooled",
        "bad",
        "emotional",
        "poor",
        "sad",
        "the dip",
        "dead",
        "broken",
        "bearish",
        "down",
        "down",
        "bad",
        "bad",
        "poor",
        "sad",
        "dead",
        "sad",
        "down"
    ];

    string[] private feelsUpTraitNames = [
        //_feels good
        "excited",
        "good",
        "amazing",
        "excellent",
        "the pump",
        "happy",
        "awesome",
        "pumped",
        "bullish",
        "happy",
        "good",
        "good",
        "excited",
        "good",
        "amazing",
        "excellent",
        "the pump",
        "happy",
        "amazing",
        "happy"
    ];

    string[] private props = [
        // props
        "",
        "",
        '" /> <polygon points="0,-34.31523 32.635724,-10.603989 20.169986,27.761605 -20.169986,27.761605 -32.635724,-10.603989 0,-34.31523" transform="translate(245.544 83.18344)" fill="', // crown [ONLY GIRLS]
        '" /> <ellipse rx="46.0897" ry="40.0938" transform="matrix(1 0 0 0.780343 245.544 414.531188)" stroke-width="7" fill ="none" stroke="', // necklace [BOTH]
        "",
        '" /> <ellipse rx="65.7083" ry="25.4094" transform="matrix(1 0 0 0.788944 244.826 38.375338)" stroke-width="7" fill="none" stroke="', // holy angel [BOTH]
        '" /> <ellipse rx="115.865" ry="220.031" transform="matrix(1.163093 0 0 0.3728 245.544 355.83783)" stroke-width="0" fill="', // hoodie should be body color
        '" /> <ellipse rx="47.366783" ry="29.377679" transform="matrix(.770232 0 0 0.391179 295.395892 191.270846)" fill="#525253"/><rect width="137.013902" height="5.577273" transform="matrix(.906317 0.091975-.100964 0.99489 148.45946 162.241458)" fill="#525253" /><rect width="137.013902" height="5.577273" transform="matrix(.327791-.120547 0.345155 0.938546 300.271209 185.216185)" fill="#525253" /><rect width="94.733566" height="27.606767" transform="matrix(.776042 0 0 0.626797 258.637 174.004902)" fill="#525253', // pirate
        '" /> <rect width="86.0899" height="42.1178" transform="translate(156.859 170.593)" fill="#452e18" fill-opacity="0.3" stroke="#484949" stroke-width="5" /><rect width="86.0899" height="42.1178" transform="translate(251.127609 171.0325)" fill="#452e18" fill-opacity="0.3" stroke="#484949" stroke-width="5" /><rect width="182.026" height="10.4645" transform="matrix(1.00726 0 0 1 153.87 160.568)" fill="#484949" /><rect width="23.6375" height="10.9892" transform="matrix(.412904-.18894 0.416095 0.909321 330.05123 163.036932)" fill="#484949" /><rect width="23.6375" height="10.9892" transform="matrix(.416574 0.198179-.430216 0.904322 151.739964 157.998826)" fill="#484949', //Glasses
        "", // tears
        '" /> <rect width="118.868229" height="14.483066" transform="matrix(.974507-.224357 0.224357 0.974507 193.851667 318.777537)" fill="#a3a2a2" /><rect width="117.462612" height="10.245869" transform="matrix(.955885 0.293741-.293741 0.955885 200.110677 290.35127)" fill="#cdc4b4', // mouth taped
        '" /> <rect width="137.013902" height="5.577273" transform="matrix(.583797 0.087276-.12938 0.865433 210.366623 332.400971)" fill="#525253" /> <rect width="137.013902" height="5.577273" transform="matrix(.089035-.427281 1.008728 0.210195 219.922568 367.065571)" fill="#525253"/> <rect width="137.013902" height="5.577273" transform="matrix(.069066-.331449 1.008728 0.210195 263.767487 366.479401)" fill="#525253" /><rect width="137.013902" height="5.577273" transform="matrix(.028809-.273678 1.626582 0.171224 245.893436 359.06473)" fill="#525253" />', // mouth sewed
        '" /> <rect width="118.868229" height="14.483066" transform="matrix(.53759-.123767-.198798-.863489 222.88375 326.108981)" fill="#c5c3c3" stroke="#f3ad4f" stroke-width="2' // rentangle mouth tilt
    ];

    string[] private earrings = [
        '" /> <polygon points="0,-10.394835 9.886076,-3.212181 6.109931,8.409598 -6.109931,8.409598 -9.886076,-3.212181 0,-10.394835" transform="matrix(-.693691 0.720273-.720273-.693691 118.406456 245.125234)" fill="', // earring polygon
        '" /> <polygon points="-1.157867,-29.675225 23.383765,12.342942 -25.699499,12.342942 -1.157867,-29.675225" transform="matrix(-.183144-.392967 0.364127-.169703 121.557811 247.040589)" fill="',
        '" /> <ellipse rx="11.672326" ry="10.611205" transform="matrix(.7294 0 0 0.828913 124.053194 244.057768)" stroke-width="9" fill="',
        ""
    ];

    string[] private hairsTypePropNames = [
        "bald",
        "short",
        "medium",
        "punk",
        "long",
        "long",
        "long",
        "long"
    ];

    string[] private hairTypes = [
        '" /> <ellipse rx="81.328" ry="110.294" transform="matrix(1.438355 0 0 1.223166 245.543665 220.929693)" fill="', // hairtype boy #1
        '" /> <ellipse rx="81.328" ry="110.294" transform="matrix(1.560897 0 0 1.341702 245.544 235.262403)" fill="', // hairtype boy #2
        '" /> <rect width="16.708" height="55.411" transform="matrix(1.075701 0 0 0.893326 236.632 78.6137)" fill="', // hairtype punk
        '" /> <ellipse rx="81.328" ry="110.294" transform="matrix(.828681 0 0 0.126043 245.544 114.212)" fill="', // hairs on forehead
        '" /> <ellipse rx="81.328" ry="110.294" transform="matrix(1.671073 0 0 1.686593 245.543665 273.911051)" fill="' // hairtype girl
    ];

    string private mu =
        '" /> <ellipse rx="69.0731" ry="65.7308" transform="matrix(.801322 0 0 0.566101 245.544001 324.148094)" fill="'; // upper mouth
    string private ml =
        '" /> <ellipse rx="69.0731" ry="65.7308" transform="matrix(.801322 0 0 0.566101 245.544001 334.201588)" fill="'; // lower mouth
    string private mn =
        '" /> <line x1="-23.674" y1="0" x2="23.674" y2="0" transform="translate(244.826115 346.639901)" stroke-width="3" stroke="'; // neutral
    string private eyebrowLeft =
        '" />   <line x1="-35.093567" y1="3.342246" x2="35.093568" y2="-3.342246" transform="matrix(.836111-.093026 0.108321 0.973584 202.652 159.603823)" stroke-width="4" stroke="'; // eyebrow left
    string private eyebrowRight =
        '" />   <line x1="-35.093567" y1="3.342246" x2="35.093568" y2="-3.342246" transform="matrix(.797604 0.267512-.311496 0.928746 290.973327 160.128534)" stroke-width="4" stroke="'; // eyebrow right

    string private p0 =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500"> <rect width="100%" height="100%" fill="';
    string private p1 =
        '" /><ellipse rx="115.865" ry="220.031" transform="matrix(.933 0 0 0.837977 245.544 567.625)" fill="';
    string private p2 =
        '" /><ellipse rx="69.0731" ry="65.7308" transform="matrix(1.69355 0 0 2.27118 245.544 250)" fill="';
    string private p3 =
        '" /> <ellipse rx="19.4964" ry="7.79857" transform="matrix(1.97143 0 0 1.71426 202.652 189.394)" fill="';
    string private p4 =
        '" /> <ellipse rx="19.4964" ry="7.79857" transform="matrix(1.8 0 0 1.71426 294.006 189.394)" fill="';
    string private p5 =
        '" /> <ellipse rx="12.254902" ry="9.469498" transform="translate(';
    string private p6 = ')" fill="';
    string private p7 =
        '" />  <ellipse rx="12.254902" ry="9.469498" transform="matrix(-.999962-.008743 0.008743-.999962 ';
    string private p8 = ')" fill="';
    string private p9 = '" /> </svg>';

    string[] private eyeLeft = [
        // eye left
        "219.451 187.801",
        "180.451 188.801",
        "179.451 188.801",
        "199.451 188.801",
        "198.451 188.801"
    ];

    string[] private eyeRight = [
        // eye right
        "290.354 187.801",
        "300.354 192.901",
        "314.354 188.901",
        "274.354 188.901",
        "294.354 188.801"
    ];

    string[] private aparts = [
        // properties metadata
        '[{ "trait_type": "Accessory", "value": "',
        '" }, { "trait_type": "Hair/Eyebrow color", "value": "',
        '" }, { "trait_type": "Shirt", "value": "',
        '" }, { "trait_type": "Face", "value": "',
        '" }, { "trait_type": "Feels up", "value": "',
        '" }, { "trait_type": "Earring", "value": "',
        '" }, { "trait_type": "Lips", "value": "',
        '" }, { "trait_type": "Gender", "value": "',
        '" }, { "trait_type": "Hairs", "value": "',
        '" }, { "trait_type": "Feels down", "value": "',
        '" }, { "trait_type": "Background", "value": "',
        '" }]'
    ];

    string[] private facePropNames = [
        "ivory",
        "porcelain",
        "pale ivory",
        "warm ivory",
        "sand",
        "rose beige",
        "livestone",
        "beige",
        "senna",
        "honey",
        "band",
        "almond",
        "peaches & cream",
        "alien",
        "zombie",
        "black"
    ];

    string[] private background = [
        "skyblue",
        "palegreen",
        "turquoise",
        "aquamarine",
        "antiquewhite",
        "azure",
        "lavender",
        "lightsteelblue",
        "plum",
        "pink",
        "thistle",
        "aqua",
        "bisque",
        "darkseagreen",
        "royalblue",
        "yellowgreen",
        "lightseagreen",
        "black"
    ];

    string[] private eyesClr = [
        "#000",
        "#FF0000",
        "#32CD32",
        "#FFF",
        "#f5b3ab"
    ];

    string[] private lipstickClr = [
        "blue",
        "red",
        "hotpink",
        "gold",
        "indigo",
        "purple",
        "olivedrab",
        "coral",
        "fuchsia",
        "white",
        ""
    ];

    string[] private faceClr = [
        "#E9CBA9",
        "#EECEB7",
        "#F7DDC4",
        "#F6E1AD",
        "#F0C795",
        "#F0C18A",
        "#E7BC8F",
        "#EDBE84",
        "#CE9D7B",
        "#CB9863",
        "#AB8963",
        "#93613C",
        "#F5E0D8",
        "#6CC417",
        "#78866B",
        "#000"
    ];

    string[] private shirtClr = [
        "darkblue",
        "cornflowerblue",
        "tomato",
        "orange",
        "white",
        "teal",
        "tan",
        "lime",
        "olive",
        "cyan",
        "chocolate",
        "peachpuff",
        "lemonchiffon",
        "black",
        "darkcyan",
        "darksalmon",
        "darkslateblue",
        "firebrick",
        "greenyellow"
    ];

    string[] private hairClr = [
        "saddlebrown",
        "deepskyblue",
        "gold",
        "yellow",
        "white",
        "mediumpurple",
        "maroon",
        "black",
        "slategray",
        "brown"
    ];

    constructor() ERC721("Mood NFT", "MN") Ownable(msg.sender) {
        s_tokenCounter = 0;
        priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
    }

    function mintNft() public {
        uint256 tokenCounter = s_tokenCounter;
        _safeMint(msg.sender, tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function getHistoricalPrice(uint80 roundId) public view returns (int256) {
        (, int256 price, , , ) = priceFeed.getRoundData(roundId - 23);
        return price;
    }

    // different function below
    function buildImage(uint256 _tokenId) public view returns (string memory) {
        Feel memory feel = randomOne(_tokenId);
        // (uint80 roundId, int256 price, , , ) = priceFeed.latestRoundData();
        // int256 histPrice = getHistoricalPrice(roundId);

        int256 percentageChange = 1;
        string memory senti = _tokenId.toString();
        uint256 eyes_clr = 3;

        // rariest black one 2 only
        if (
            feel.hairtype == 0 &&
            feel.hairclr == 7 &&
            feel.shirtClr == 13 &&
            (feel.lipsclr != 5) &&
            !(feel.prop == 6 ||
                feel.prop == 4 ||
                feel.prop == 2 ||
                (feel.prop == 5 && feel.lipsclr > 4))
        ) {
            feel.bg = 18;
            feel.faceClr = 15;
        }
        // Background
        string memory makingFeel = string(
            abi.encodePacked(p0, background[feel.bg])
        );

        if (feel.eyesd == 3 && feel.prop == 10) {
            feel.faceClr = 13; // alien
        }
        if (feel.eyesd == 4 && feel.prop == 11) {
            feel.faceClr = 14; // zombie
        }

        if (feel.hairtype > 3) {
            // girl
            makingFeel = string(
                abi.encodePacked(
                    makingFeel,
                    hairTypes[4],
                    hairClr[feel.hairclr]
                )
            );
        } else {
            if (feel.lipsclr < 3 && feel.hairtype == 0) {
                feel.hairtype = 1;
            }
            if (feel.lipsclr > 6 && feel.hairtype == 3) {
                feel.hairtype = 2;
            }
            if (feel.hairtype > 0) {
                // boys hairClr 1
                makingFeel = string(
                    abi.encodePacked(
                        makingFeel,
                        hairTypes[feel.hairtype - 1],
                        hairClr[feel.hairclr]
                    )
                ); // single or bald style
            }
            // ears
            makingFeel = string(
                abi.encodePacked(
                    makingFeel,
                    ear1,
                    faceClr[feel.faceClr],
                    ear2,
                    faceClr[feel.faceClr]
                )
            );
        }
        // prop crown - rarity fig
        if (feel.hairtype > 3 && (feel.prop == 11 || feel.prop == 10)) {
            feel.prop = 2;
        }

        // body
        makingFeel = string(
            abi.encodePacked(makingFeel, p1, shirtClr[feel.shirtClr])
        );

        // props
        if (feel.prop > 1 && feel.prop < 7) {
            if (feel.hairtype < 4) {
                // boy
                if (feel.prop == 2) {
                    feel.prop = 6;
                }
            }

            if (
                feel.prop == 6 ||
                feel.prop == 4 ||
                (feel.prop == 5 && feel.lipsclr > 4)
            ) {
                feel.prop = 6;
                makingFeel = string(
                    abi.encodePacked(
                        makingFeel,
                        props[6],
                        shirtClr[feel.shirtClr]
                    )
                ); // hoodie
            } else {
                makingFeel = string(
                    abi.encodePacked(
                        makingFeel,
                        props[feel.prop],
                        faceClr[feel.faceClr + 1]
                    )
                );
            }
        }

        // stoned
        if (feel.prop == 0 && (feel.eyesd < 2)) {
            eyes_clr = 4;
        }

        // face
        makingFeel = string(
            abi.encodePacked(
                makingFeel,
                p2,
                faceClr[feel.faceClr],
                p3,
                eyesClr[eyes_clr],
                p4,
                eyesClr[eyes_clr]
            )
        );

        // prop earring
        if (feel.earring < 3) {
            makingFeel = string(
                abi.encodePacked(
                    makingFeel,
                    earrings[feel.earring],
                    lipstickClr[feel.lipsclr]
                )
            );
        } else {
            feel.earring = 3;
        }

        // bald or forehead hairtype
        if (feel.hairtype != 3 && feel.hairtype != 0) {
            makingFeel = string(
                abi.encodePacked(
                    makingFeel,
                    hairTypes[3],
                    hairClr[feel.hairclr]
                )
            );
        }
        // *********** PRICE CHANGE LOGIC *********** //
        if (percentageChange < -1) {
            eyes_clr = 1;
            senti = feelsDownTraitNames[feel.feel_down];
            if ((feel.prop > 10) && feel.eyesd < 3) {
                // fancy mouths
                makingFeel = string(
                    abi.encodePacked(makingFeel, props[10 + feel.eyesd])
                );
            } else {
                if (feel.hairtype < 4) {
                    feel.lipsclr = 9;
                }
                makingFeel = string(
                    abi.encodePacked(
                        makingFeel,
                        mu,
                        lipstickClr[feel.lipsclr],
                        ml,
                        faceClr[feel.faceClr]
                    )
                );
            }
        } else if (percentageChange > -2 && percentageChange < 2) {
            eyes_clr = 0;
            senti = "ok";
            if ((feel.prop > 10) && feel.eyesd < 2) {
                makingFeel = string(
                    abi.encodePacked(makingFeel, props[10 + feel.eyesd])
                ); // fancy mouths
            } else {
                if (feel.hairtype < 4) {
                    feel.lipsclr = 9;
                }
                makingFeel = string(
                    abi.encodePacked(makingFeel, mn, lipstickClr[feel.lipsclr])
                );
            }
        } else {
            eyes_clr = 2;
            senti = feelsUpTraitNames[feel.feel_up];
            if ((feel.prop > 10) && feel.eyesd < 2) {
                makingFeel = string(
                    abi.encodePacked(makingFeel, props[10 + feel.eyesd])
                ); // fancy mouths
            } else {
                if (feel.hairtype < 4) {
                    feel.lipsclr = 9;
                }
                makingFeel = string(
                    abi.encodePacked(
                        makingFeel,
                        ml,
                        lipstickClr[feel.lipsclr],
                        mu,
                        faceClr[feel.faceClr]
                    )
                );
            }
        }

        makingFeel = string(
            abi.encodePacked(
                makingFeel,
                p5,
                eyeLeft[feel.eyesd],
                p6,
                eyesClr[eyes_clr],
                p7
            )
        );
        makingFeel = string(
            abi.encodePacked(
                makingFeel,
                eyeRight[feel.eyesd],
                p8,
                eyesClr[eyes_clr],
                eyebrowLeft,
                hairClr[feel.hairclr]
            )
        );
        makingFeel = string(
            abi.encodePacked(makingFeel, eyebrowRight, hairClr[feel.hairclr])
        );
        if (feel.prop > 6 && feel.prop < 9) {
            makingFeel = string(
                abi.encodePacked(makingFeel, props[feel.prop], p9)
            );
        } else {
            if (feel.prop < 2) {
                if (feel.prop == 0 && (feel.eyesd < 2)) {
                    //stoned
                    feel.prop = 9;
                }
            } else if (feel.prop > 8) {
                if ((feel.prop > 10) && feel.eyesd < 2) {
                    feel.prop = feel.eyesd + 11;
                    feel.lipsclr = 10;
                } else {
                    feel.prop = 0;
                }
            }

            makingFeel = string(abi.encodePacked(makingFeel, p9));
        }
        return
            buildMetadata(
                Base64.encode(bytes(makingFeel)),
                feel,
                senti,
                _tokenId
            );
    }

    // helper function
    function toString(uint256 _value) public pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        if (_value == 0) {
            return "0";
        }
        uint256 temp = _value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(_value % 10)));
            _value /= 10;
        }
        return string(buffer);
    }

    // generate randomness
    function randomOne(uint256 _tokenId) public pure returns (Feel memory) {
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(
                    string(abi.encodePacked("Feels", _tokenId.toString()))
                )
            )
        );
        Feel memory newFeel = Feel(
            ((rand) % 17), // bg : type int
            ((rand) % 13), // faceclr
            ((rand) % 19), // shirtclr
            ((rand) % 10), // hairclr
            ((rand) % 16), // prop,
            ((rand) % 12), // earring,
            ((rand) % 7), // hairtype,
            ((rand) % 9), // lipsclr
            ((rand) % 5), // eyesd
            ((rand) % 20), // Feel up
            ((rand) % 21) // Feel down
        );
        return newFeel;
    }

    function buildMetadata(
        string memory image,
        Feel memory _feel,
        string memory _feels,
        uint256 _tokenId
    ) public view returns (string memory) {
        string memory gend = "female";
        if (_feel.hairtype < 4) {
            gend = "male";
        }

        string memory strparams = string(
            abi.encodePacked(
                aparts[0],
                pn[_feel.prop],
                aparts[1],
                hairClr[_feel.hairclr],
                aparts[2],
                shirtClr[_feel.shirtClr],
                aparts[3],
                facePropNames[_feel.faceClr],
                aparts[4],
                feelsUpTraitNames[_feel.feel_up],
                aparts[5]
            )
        );
        strparams = string(
            abi.encodePacked(
                strparams,
                pn[_feel.earring + 14],
                aparts[6],
                lipstickClr[_feel.lipsclr],
                aparts[7],
                gend,
                aparts[8],
                hairsTypePropNames[_feel.hairtype],
                aparts[9],
                feelsDownTraitNames[_feel.feel_down]
            )
        );
        strparams = string(
            abi.encodePacked(
                strparams,
                aparts[10],
                background[_feel.bg],
                aparts[11]
            )
        );
        // strparams = string(abi.encodePacked(strparams, feelsDownTraitNames[_feel.bg]));
        return
            string(
                abi.encodePacked(
                    md1,
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"#',
                                _tokenId.toString(),
                                " feels ",
                                _feels,
                                '", "attributes":',
                                strparams,
                                ', "image": "',
                                md2,
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    // different function above

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert ERC721Metadata__URI_QueryFor_NonExistentToken();
        }

        string memory imageURI = buildImage(tokenId);
        return imageURI;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
