-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 05, 2025 at 10:59 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `localconnect`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id`, `user_id`, `name`, `email`) VALUES
(1, 1, 'Admin1', 'admin@example.com');

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `attendance_id` int(11) NOT NULL,
  `faculty_id` int(11) NOT NULL,
  `semester_id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `attendance_date` date NOT NULL,
  `hours` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`attendance_id`, `faculty_id`, `semester_id`, `subject_id`, `attendance_date`, `hours`, `created_at`) VALUES
(1, 23, 2, 1, '2025-04-02', 2, '2025-04-02 09:58:10'),
(2, 23, 6, 3, '2025-04-02', 1, '2025-04-02 11:55:52'),
(3, 23, 2, 1, '2025-04-02', 1, '2025-04-02 12:38:52'),
(4, 23, 6, 3, '2025-04-04', 1, '2025-04-04 03:03:28'),
(5, 23, 2, 1, '2025-04-04', 2, '2025-04-04 04:41:03');

-- --------------------------------------------------------

--
-- Table structure for table `attendance_details`
--

CREATE TABLE `attendance_details` (
  `id` int(11) NOT NULL,
  `attendance_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `status` enum('present','absent') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attendance_details`
--

INSERT INTO `attendance_details` (`id`, `attendance_id`, `student_id`, `status`) VALUES
(1, 1, 23, 'absent'),
(2, 1, 26, 'present'),
(3, 1, 20, 'present'),
(4, 1, 21, 'present'),
(5, 1, 25, 'present'),
(6, 1, 22, 'present'),
(7, 1, 24, 'present'),
(8, 2, 14, 'present'),
(9, 2, 3, 'absent'),
(10, 3, 23, 'present'),
(11, 3, 26, 'absent'),
(12, 3, 20, 'absent'),
(13, 3, 21, 'present'),
(14, 3, 25, 'present'),
(15, 3, 22, 'present'),
(16, 3, 24, 'present'),
(17, 4, 14, 'absent'),
(18, 4, 3, 'absent'),
(19, 5, 23, 'present'),
(20, 5, 26, 'absent'),
(21, 5, 20, 'absent'),
(22, 5, 21, 'present'),
(23, 5, 25, 'present'),
(24, 5, 22, 'present'),
(25, 5, 24, 'present');

-- --------------------------------------------------------

--
-- Table structure for table `classes`
--

CREATE TABLE `classes` (
  `id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  `semester` int(11) NOT NULL,
  `class_name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `classes`
--

INSERT INTO `classes` (`id`, `department_id`, `semester`, `class_name`, `created_at`) VALUES
(1, 1, 1, 'Semester 1 - Department 1', '2025-03-12 18:54:12'),
(2, 1, 2, 'Semester 2 - Department 1', '2025-03-12 18:54:12'),
(3, 1, 3, 'Semester 3 - Department 1', '2025-03-12 18:54:12'),
(4, 1, 4, 'Semester 4 - Department 1', '2025-03-12 18:54:12'),
(5, 1, 5, 'Semester 5 - Department 1', '2025-03-12 18:54:12'),
(6, 1, 6, 'Semester 6 - Department 1', '2025-03-12 18:54:12'),
(7, 1, 7, 'Semester 7 - Department 1', '2025-03-12 18:54:12'),
(8, 1, 8, 'Semester 8 - Department 1', '2025-03-12 18:54:12'),
(9, 2, 1, 'Semester 1 - Department 2', '2025-03-12 18:54:12'),
(10, 2, 2, 'Semester 2 - Department 2', '2025-03-12 18:54:12'),
(11, 2, 3, 'Semester 3 - Department 2', '2025-03-12 18:54:12'),
(12, 2, 4, 'Semester 4 - Department 2', '2025-03-12 18:54:12'),
(13, 2, 5, 'Semester 5 - Department 2', '2025-03-12 18:54:12'),
(14, 2, 6, 'Semester 6 - Department 2', '2025-03-12 18:54:12'),
(15, 2, 7, 'Semester 7 - Department 2', '2025-03-12 18:54:12'),
(16, 2, 8, 'Semester 8 - Department 2', '2025-03-12 18:54:12'),
(17, 3, 1, 'Semester 1 - Department 3', '2025-03-12 18:54:12'),
(18, 3, 2, 'Semester 2 - Department 3', '2025-03-12 18:54:12'),
(19, 3, 3, 'Semester 3 - Department 3', '2025-03-12 18:54:12'),
(20, 3, 4, 'Semester 4 - Department 3', '2025-03-12 18:54:12'),
(21, 3, 5, 'Semester 5 - Department 3', '2025-03-12 18:54:12'),
(22, 3, 6, 'Semester 6 - Department 3', '2025-03-12 18:54:12'),
(23, 3, 7, 'Semester 7 - Department 3', '2025-03-12 18:54:12'),
(24, 3, 8, 'Semester 8 - Department 3', '2025-03-12 18:54:12'),
(25, 4, 1, 'Semester 1 - Department 4', '2025-03-12 18:54:12'),
(26, 4, 2, 'Semester 2 - Department 4', '2025-03-12 18:54:12'),
(27, 4, 3, 'Semester 3 - Department 4', '2025-03-12 18:54:12'),
(28, 4, 4, 'Semester 4 - Department 4', '2025-03-12 18:54:12'),
(29, 4, 5, 'Semester 5 - Department 4', '2025-03-12 18:54:12'),
(30, 4, 6, 'Semester 6 - Department 4', '2025-03-12 18:54:12'),
(31, 4, 7, 'Semester 7 - Department 4', '2025-03-12 18:54:12'),
(32, 4, 8, 'Semester 8 - Department 4', '2025-03-12 18:54:12'),
(33, 5, 1, 'Semester 1 - Department 5', '2025-03-12 18:54:12'),
(34, 5, 2, 'Semester 2 - Department 5', '2025-03-12 18:54:12'),
(35, 5, 3, 'Semester 3 - Department 5', '2025-03-12 18:54:12'),
(36, 5, 4, 'Semester 4 - Department 5', '2025-03-12 18:54:12'),
(37, 5, 5, 'Semester 5 - Department 5', '2025-03-12 18:54:12'),
(38, 5, 6, 'Semester 6 - Department 5', '2025-03-12 18:54:12'),
(39, 5, 7, 'Semester 7 - Department 5', '2025-03-12 18:54:12'),
(40, 5, 8, 'Semester 8 - Department 5', '2025-03-12 18:54:12');

-- --------------------------------------------------------

--
-- Table structure for table `class_subjects`
--

CREATE TABLE `class_subjects` (
  `id` int(11) NOT NULL,
  `class_id` int(11) DEFAULT NULL,
  `subject_id` int(11) DEFAULT NULL,
  `faculty_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `depid` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `name`, `depid`) VALUES
(1, 'Computer Science', 'CSE'),
(2, 'Cyber Security', 'CYS'),
(3, 'Electronics and Communication', 'ECE'),
(4, 'Electrical and Electronics', 'EEE'),
(5, 'Polymer Engineering', 'PO');

-- --------------------------------------------------------

--
-- Table structure for table `faculty`
--

CREATE TABLE `faculty` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `department_id` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `faculty`
--

INSERT INTO `faculty` (`id`, `user_id`, `name`, `department_id`, `email`) VALUES
(1, 3, 'faculty1', 'ECE', 'faculty@mail.com'),
(2, 4, 'teacher', 'ECE', 'teacher@gmail.com'),
(23, 28, 'Lini Miss', 'CSE', 'faculty2@gmail.com'),
(25, 31, 'faculty3', 'ECE', 'faculty3@gmail.com'),
(26, 32, 'faculty4', 'ECE', 'faculty4@gmail.com'),
(27, 33, 'faculty5', 'CYS', 'faculty5@gmail.com'),
(28, 36, 'faculty6', 'PO', 'faculty6@gmail.com'),
(29, 37, 'faculty7', 'PO', 'faculty7@gmail.com'),
(34, 120, 'teacher3', 'ECE', 'teacher3@gmail.com'),
(35, 121, 'teacher2', 'CSE', 'teacher2@gmail.com'),
(37, 135, 'TEACHER', 'CSE', 'i@gmail.com'),
(38, 136, 'reghu', 'CSE', 'abc.gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `semesters`
--

CREATE TABLE `semesters` (
  `id` int(11) NOT NULL,
  `semester` enum('S1','S2','S3','S4','S5','S6','S7','S8') NOT NULL,
  `semester_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `semesters`
--

INSERT INTO `semesters` (`id`, `semester`, `semester_id`) VALUES
(1, 'S1', 1),
(2, 'S2', 2),
(3, 'S3', 3),
(4, 'S4', 4),
(5, 'S5', 5),
(6, 'S6', 6),
(7, 'S7', 7),
(8, 'S8', 8);

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `department_id` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `semester` enum('S1','S2','S3','S4','S5','S6','S7','S8') NOT NULL,
  `semester_st` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`id`, `user_id`, `name`, `department_id`, `email`, `semester`, `semester_st`) VALUES
(3, 35, 'student', 'CSE', 'student@gmail.com', 'S6', 6),
(4, 38, 'student2', 'ECE', 'student2@gmail.com', 'S3', 3),
(7, 41, 'student3', 'ECE', 'student3@gmail.com', 'S3', 3),
(14, 128, 'adhil', 'CSE', 'adhilkhakkim@gmail.com', 'S6', 6),
(15, 130, 'lathee', 'CSE', 'lathee@gmail.com', 'S4', 4),
(16, 132, 'student8', 'ECE', 'student8@gmail.com', 'S3', 3),
(17, 133, 'student9', 'CSE', 'student9@gmail.com', 'S5', 5),
(20, 50, 'Ibrahim', 'CSE', 'ibrayi@gmail.com', 'S2', 2),
(21, 51, 'Ijas', 'CSE', 'ijas@gmail.com', 'S2', 2),
(22, 52, 'Pranav', 'CSE', 'pranav@gmail.com', 'S2', 2),
(23, 53, 'Adil', 'CSE', 'adil@gmail.com', 'S2', 2),
(24, 54, 'Shamil', 'CSE', 'shamil@gmail.com', 'S2', 2),
(25, 55, 'Manuith', 'CSE', 'manu@gmail.com', 'S2', 2),
(26, 56, 'Fredy', 'CSE', 'fr@gmail.com', 'S2', 2),
(27, 137, 'akhil', 'PO', 'akhil@gmail.com', 'S4', NULL),
(28, 138, 'Sabith', 'CYS', 'shaimunni@gmail.com', 'S2', NULL),
(29, 139, 'Nafi', 'CYS', 'nafi@gmail.com', 'S6', 6);

-- --------------------------------------------------------

--
-- Table structure for table `students_backup`
--

CREATE TABLE `students_backup` (
  `id` int(11) NOT NULL DEFAULT 0,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `department_id` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `semester` enum('S1','S2','S3','S4','S5','S6','S7','S8') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `id` int(11) NOT NULL,
  `department_id` int(11) DEFAULT NULL,
  `semester` int(11) NOT NULL,
  `subject_name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`id`, `department_id`, `semester`, `subject_name`, `created_at`, `start_date`, `end_date`) VALUES
(1, 1, 2, 'data structure', '2025-03-12 19:42:19', NULL, NULL),
(2, 2, 2, 'CYBER', '2025-03-13 08:18:43', NULL, NULL),
(3, 1, 6, 'algorithm', '2025-03-12 18:30:00', NULL, NULL),
(4, 1, 2, 'java', '2025-04-03 04:20:19', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `subjects_faculty`
--

CREATE TABLE `subjects_faculty` (
  `id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  `semester` int(10) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `faculty_id` int(10) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `subjects_faculty`
--

INSERT INTO `subjects_faculty` (`id`, `department_id`, `semester`, `subject_id`, `faculty_id`, `start_date`, `end_date`) VALUES
(8, 1, 2, 1, 23, NULL, NULL),
(9, 2, 2, 2, 2, NULL, NULL),
(10, 1, 6, 3, 23, NULL, NULL),
(11, 1, 2, 4, 25, '2025-04-16', '2025-04-18');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','faculty','student') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `role`) VALUES
(1, 'PUCE22', '123456', 'admin'),
(3, 'FUCE22', '123456', 'faculty'),
(4, 'FUCE221', '123456', 'faculty'),
(28, 'FUCE23', '123456', 'faculty'),
(31, 'FUCE24', '123456', 'faculty'),
(32, 'FUCE25', '123456', 'faculty'),
(33, 'FUCE26', '123456', 'faculty'),
(35, 'UCE22', '123456', 'student'),
(36, 'FUCE27', '123456', 'faculty'),
(37, 'FUCE28', '123456', 'faculty'),
(38, 'UCE24', '123456', 'student'),
(41, 'UCE25', '123456', 'student'),
(50, 'uce10', '123456', 'student'),
(51, 'uce11', '123456', 'student'),
(52, 'uce12', '123456', 'student'),
(53, 'uce13', '123456', 'student'),
(54, 'uce14', '123456', 'student'),
(55, 'uce15', '123456', 'student'),
(56, 'uce16', '123456', 'student'),
(120, 'FUCE29', '123456', 'faculty'),
(121, 'FUCE30', '123456', 'faculty'),
(128, 'UCE22CS048', 'adhil123', 'student'),
(130, 'UCE22CS3', '123456', 'student'),
(132, 'UCE29', '123456', 'student'),
(133, 'UCE30', '123456', 'student'),
(135, 'FUCE20', '123456', 'faculty'),
(136, 'ruce123', '123456', 'faculty'),
(137, 'uce23po1', '123456', 'student'),
(138, 'UCE09', '123456', 'student'),
(139, 'uce01', '123456', 'student');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`attendance_id`),
  ADD UNIQUE KEY `unique_attendance_session` (`faculty_id`,`subject_id`,`attendance_date`,`hours`),
  ADD KEY `semester` (`semester_id`),
  ADD KEY `subject` (`subject_id`),
  ADD KEY `f` (`faculty_id`),
  ADD KEY `faculty_date_idx` (`faculty_id`,`attendance_date`);

--
-- Indexes for table `attendance_details`
--
ALTER TABLE `attendance_details`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_student_attendance` (`attendance_id`,`student_id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `attendance_idx` (`attendance_id`);

--
-- Indexes for table `classes`
--
ALTER TABLE `classes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `semester` (`semester`);

--
-- Indexes for table `class_subjects`
--
ALTER TABLE `class_subjects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `class_id` (`class_id`),
  ADD KEY `subject_id` (`subject_id`),
  ADD KEY `faculty_id` (`faculty_id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `depid` (`depid`) USING BTREE;

--
-- Indexes for table `faculty`
--
ALTER TABLE `faculty`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `department_id` (`department_id`);

--
-- Indexes for table `semesters`
--
ALTER TABLE `semesters`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `semester_id` (`semester_id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `semester_st` (`semester_st`) USING BTREE;

--
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `subjects_ibfk_1` (`semester`);

--
-- Indexes for table `subjects_faculty`
--
ALTER TABLE `subjects_faculty`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `subject_id` (`subject_id`),
  ADD KEY `dept` (`department_id`),
  ADD KEY `faculty` (`faculty_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `attendance_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `attendance_details`
--
ALTER TABLE `attendance_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `classes`
--
ALTER TABLE `classes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `class_subjects`
--
ALTER TABLE `class_subjects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `faculty`
--
ALTER TABLE `faculty`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `semesters`
--
ALTER TABLE `semesters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `subjects_faculty`
--
ALTER TABLE `subjects_faculty`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=140;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin`
--
ALTER TABLE `admin`
  ADD CONSTRAINT `admin_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`faculty_id`) REFERENCES `faculty` (`id`),
  ADD CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`id`),
  ADD CONSTRAINT `attendance_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`);

--
-- Constraints for table `attendance_details`
--
ALTER TABLE `attendance_details`
  ADD CONSTRAINT `attendance_details_ibfk_1` FOREIGN KEY (`attendance_id`) REFERENCES `attendance` (`attendance_id`),
  ADD CONSTRAINT `attendance_details_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`);

--
-- Constraints for table `classes`
--
ALTER TABLE `classes`
  ADD CONSTRAINT `classes_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `classes_ibfk_2` FOREIGN KEY (`semester`) REFERENCES `semesters` (`id`);

--
-- Constraints for table `class_subjects`
--
ALTER TABLE `class_subjects`
  ADD CONSTRAINT `class_subjects_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `class_subjects_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `class_subjects_ibfk_3` FOREIGN KEY (`faculty_id`) REFERENCES `faculty` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `faculty`
--
ALTER TABLE `faculty`
  ADD CONSTRAINT `faculty_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`depid`) ON DELETE CASCADE,
  ADD CONSTRAINT `faculty_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`depid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `students_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `students_ibfk_3` FOREIGN KEY (`semester_st`) REFERENCES `semesters` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `subjects`
--
ALTER TABLE `subjects`
  ADD CONSTRAINT `subjects_ibfk_1` FOREIGN KEY (`semester`) REFERENCES `semesters` (`semester_id`) ON DELETE CASCADE;

--
-- Constraints for table `subjects_faculty`
--
ALTER TABLE `subjects_faculty`
  ADD CONSTRAINT `dept` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  ADD CONSTRAINT `faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculty` (`id`),
  ADD CONSTRAINT `subject_id` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
