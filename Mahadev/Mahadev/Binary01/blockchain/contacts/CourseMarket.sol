// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CourseMarketplace {
    struct Course {
        string cid; // IPFS CID of the course file
        address author;
        uint256 price;
        uint256 resalePrice;
        uint256 maxResales;
        uint256 resales;
        address currentOwner;
        bool sold;
    }

    mapping(uint256 => Course) public courses;
    mapping(address => uint256[]) public userCourses;
    uint256 public nextCourseId = 1;
    address payable public platformAddress;

    event CourseCreated(uint256 indexed courseId, string cid, uint256 price, address indexed author);
    event CoursePurchased(uint256 indexed courseId, address indexed buyer, uint256 price);
    event CourseListedForResale(uint256 indexed courseId, address indexed owner, uint256 resalePrice);
    event CourseResold(uint256 indexed courseId, address indexed seller, address indexed newOwner, uint256 price);

    modifier onlyOwner(uint256 courseId) {
        require(msg.sender == courses[courseId].currentOwner, "Not the course owner");
        _;
    }

    modifier courseExists(uint256 courseId) {
        require(courses[courseId].author != address(0), "Course does not exist");
        _;
    }

    modifier reentrancyGuard() {
        require(!locked, "Reentrancy detected");
        locked = true;
        _;
        locked = false;
    }

    bool private locked;

    constructor(address payable _platformAddress) {
        require(_platformAddress != address(0), "Invalid platform address");
        platformAddress = _platformAddress;
    }

    /// 📌 Author uploads a course
    function createCourse(
        string memory _cid,
        uint256 _price,
        uint256 _resalePrice,
        uint256 _maxResales
    ) external {
        require(_price > 0, "Price must be greater than zero");
        require(_resalePrice > 0, "Resale price must be greater than zero");

        uint256 courseId = nextCourseId++;
        courses[courseId] = Course({
            cid: _cid,
            author: msg.sender,
            price: _price,
            resalePrice: _resalePrice,
            maxResales: _maxResales,
            resales: 0,
            currentOwner: msg.sender,
            sold: false
        });

        emit CourseCreated(courseId, _cid, _price, msg.sender);
    }

    /// 📌 First Buyer buys a course at full price (100% goes to the original author)
    function buyCourse(uint256 courseId) external payable courseExists(courseId) reentrancyGuard {
        Course storage course = courses[courseId];
        require(!course.sold, "Course already sold");
        require(msg.value == course.price, "Incorrect payment amount");

        course.sold = true;
        course.currentOwner = msg.sender;
        userCourses[msg.sender].push(courseId);

        // Pay the original author
        (bool success, ) = course.author.call{value: msg.value}("");
        require(success, "Payment to author failed");

        emit CoursePurchased(courseId, msg.sender, msg.value);
    }

    /// 📌 Resell the course at a fixed resale price
    function resellCourse(uint256 courseId) external onlyOwner(courseId) {
        Course storage course = courses[courseId];
        require(course.resales < course.maxResales, "Resale limit reached");

        course.sold = false;
        course.resales++;

        emit CourseListedForResale(courseId, msg.sender, course.resalePrice);
    }

    /// 📌 Buyer purchases the resold course at a fixed resale price
    function buyResoldCourse(uint256 courseId) external payable courseExists(courseId) reentrancyGuard {
        Course storage course = courses[courseId];
        require(!course.sold, "Already sold");
        require(course.resales <= course.maxResales, "Resale limit reached");
        require(msg.value == course.resalePrice, "Incorrect payment amount");

        address previousOwner = course.currentOwner;
        course.currentOwner = msg.sender;
        course.sold = true;

        // Platform and Seller Payments
        uint256 platformCut = (msg.value * 20) / 100;
        uint256 sellerCut = msg.value - platformCut;

        (bool platformPaid, ) = platformAddress.call{value: platformCut}("");
        require(platformPaid, "Platform payment failed");

        (bool sellerPaid, ) = payable(previousOwner).call{value: sellerCut}("");
        require(sellerPaid, "Seller payment failed");

        userCourses[msg.sender].push(courseId);

        emit CourseResold(courseId, previousOwner, msg.sender, msg.value);
    }

    /// 📌 Get CID of purchased course
    function getCourseCID(uint256 courseId) external view onlyOwner(courseId) returns (string memory) {
        return courses[courseId].cid;
    }

    /// 📌 Get all courses owned by a user
    function getUserCourses(address user) external view returns (uint256[] memory) {
        return userCourses[user];
    }
}
