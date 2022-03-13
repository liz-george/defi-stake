  // SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MetaNFT is ERC721 {
    uint256 private totalTokensMint;
    uint256 private _totalSupply;

    event Received(address, uint);

    mapping(uint256 => string) private tokenIdToUri;

    constructor () ERC721 ("MetaFin NFT", "MTF"){
    }

    
   ///  @notice Creates new NFT for the user
    function mintNft(address user, string memory ipfsHash) external returns(bool) {
        totalTokensMint++;
        tokenIdToUri[totalTokensMint] = ipfsHash;
        _safeMint(user, totalTokensMint);
        _totalSupply++;
        return true;
    }

    /// @notice Transfer NFT to another account
     function transfer(address _to,uint256 _tokenId) external {
        safeTransferFrom(msg.sender, _to, _tokenId);
    }


 /// @notice Return tokenURI 
    function tokenURI(uint256 tokenId) 
        public
        view 
        virtual 
        override 
        returns (string memory) 
    {
        return string(abi.encodePacked(_baseURI(),tokenIdToUri[tokenId]));
    }

  /// @notice Return the base URI 
    function _baseURI() 
        internal 
        view 
        virtual  
        override
        returns (string memory) 
    {
        return "https://ipfs.io/ipfs/";
    }

     /// @notice Return total supply for NFT
    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }
}