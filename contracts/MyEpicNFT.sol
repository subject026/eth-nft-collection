// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";


contract MyEpicNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  uint public maxTokens = 30;
  
  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: darkgreen; font-family: sans-serif; font-size: 24px; font-weight: bold; }</style><rect width='100%' height='100%' fill='pink' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string[] firstWords = ["adequate", "complex", "cathartic", "quick", "nice", "impossible", "hot", "slow", "deep", "cool", "strong", "perfect", "tragic", "holistic", "pragmatic", "inspirational", "unbelievable", "inviting", "clueless", "extreme"];
  string[] secondWords = ["bean", "lentil", "oat", "broccoli", "kale", "cauliflower", "cheese", "burrito", "falafel", "leek", "pumpkin", "souffle", "lasagne", "pakora", "rice", "ragu", "bread", "wine", "fish", "prawn"];
  string[] thirdWords = ["cake", "party", "feast", "congress", "collective", "blockchain", "DApp", "runtime", "disaster", "meeting", "trial", "standoff", "compromise", "birth", "weighting", "solution", "design", "cataclysm"];

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("SquareNFT", "SQUARE") {
    console.log("I'm a pretty big deal in the crypto space");
  }

  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    // seed the random generator
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();
    require(newItemId < maxTokens, string(abi.encodePacked("Max number of tokens have already been minted!")));

    // We go and randomly grab one word from each of the three arrays.
    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, " ", second, " ", third));

    // I concatenate it all together, and then close the <text> and <svg> tags.
    string memory finalSvg = string(abi.encodePacked(baseSvg, first, " ", second, " ", third, "</text></svg>"));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "There was one weird trick to smashing out these NFTS", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );
    
    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    // console.log("\n--------------------");
    // console.log(finalTokenUri);
    // console.log("--------------------\n");

    // console.log("\n--------------------");
    // console.log(
    //     string(
    //         abi.encodePacked(
    //             "https://nftpreview.0xdev.codes/?code=",
    //             finalTokenUri
    //         )
    //     )
    // );
    // console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
  
    // We'll be setting the tokenURI later!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("woop woop yes it's true An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    emit NewEpicNFTMinted(msg.sender, newItemId);
  }

  struct CurrentMinted {
    uint256 totalMinted;
    uint256 leftToMint;
  }

  function getCurrentMinted() public view returns (CurrentMinted memory) {
    uint256 totalMinted = _tokenIds.current();
    uint leftToMint = maxTokens - totalMinted;
    return CurrentMinted(totalMinted, leftToMint);
  }
}