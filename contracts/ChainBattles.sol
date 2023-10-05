// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Stats {
        uint256 level;
        uint256 wisdom;
        string alignment;
    }

    mapping (uint256 => Stats) public tokenIdToStats;

    constructor() ERC721("ChainBattles", "CBTLS") {}

    // dynamically generate the image for the token based on stats
    function generateImage(uint256 tokenId) public view returns (string memory) {
    bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="purple" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Wizard",'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',"Level: ",getLevel(tokenId),'</text>',
        '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',"Wisdom: ",getWisdom(tokenId),'</text>',
        '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',"Alignment: ",getAlignment(tokenId),'</text>',
        '</svg>'
        );

        return string(
        abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(svg)
        ));
    }

    // getters
    function getLevel(uint256 tokenId) public view returns (string memory) {
        uint256 level = tokenIdToStats[tokenId].level;
        return level.toString();
    }

    function getWisdom(uint256 tokenId) public view returns (string memory) {
        uint256 wisdom = tokenIdToStats[tokenId].wisdom;
        return wisdom.toString();
    }

    function getAlignment(uint256 tokenId) public view returns (string memory) {
        string memory alignment = tokenIdToStats[tokenId].alignment;
        return alignment;
    }

    // create URI for token based on stats
    function makeTokenURI(uint256 tokenId) public view returns (string memory){
    bytes memory dataURI = abi.encodePacked(
        '{',
            '"name": "Wizard #', tokenId.toString(), '",',
            '"description": "A wizard battling others onchain",',
            '"image": "', generateImage(tokenId), '",',
            '"attributes": [{',
                '"trait_type": "Level"', ',',
                '"value":', getLevel(tokenId),
                '}', ',',
                '{',
                '"trait_type": "Wisdom"', ',',
                '"value":', getWisdom(tokenId),
                '}', ',',
                '{',
                '"trait_type": "Alignment"', ',',
                '"value": "', getAlignment(tokenId), '"',
                '}', 
            ']',
        '}'
    );
    return string(
        abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(dataURI)
        )
    );
    }

    function randomNumber(uint256 size) internal view returns (uint256) {
        uint256 num = uint (keccak256(abi.encodePacked (block.prevrandao, block.timestamp))) % size;
        return num;
     }

    function decideAlignment() internal view returns (string memory) {
        uint256 num = randomNumber(2);
        if (num == 0) {
            return "Cthulhu";
        } else if (num == 1) {
            return "Nyarlathotep";
        } else if (num == 2) {
            return "Azathoth";
        }
        // Add default return value
        return "Unknown";  
    }

    function makeWizard() private view returns (Stats memory) {
        Stats memory stats;
        stats.level = 1;
        stats.wisdom = randomNumber(9);
        stats.alignment = decideAlignment();
        return stats;
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        // create a wizard
        tokenIdToStats[newItemId] = makeWizard();
        _setTokenURI(newItemId, makeTokenURI(newItemId));
    }

    // train your wizard
    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "Not owner");

        uint256 currentLevel = tokenIdToStats[tokenId].level;
        tokenIdToStats[tokenId].level = currentLevel + 1;

        uint256 currentWisdom = tokenIdToStats[tokenId].wisdom;
        tokenIdToStats[tokenId].wisdom = currentWisdom + 1;

        // update URI with new metadata
        _setTokenURI(tokenId, makeTokenURI(tokenId));
    }
}
