-- SCHOOL MANAGEMENT SYSTEM 
-- Run the whole file with Ctrl+Shift+Enter in Workbench
-- Clean start (deletes the old database if it exists)

DROP DATABASE IF EXISTS school_management;
CREATE DATABASE school_management;
USE school_management;

-- 1. TABLES (parents first, children last)

-- 1. STUDENTS
CREATE TABLE students (
    student_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL,
    phone           VARCHAR(20)  NULL,
    date_of_birth   DATE         NOT NULL,
    gender          ENUM('Male','Female','Other') NULL,
    address         VARCHAR(255) NULL,
   admission_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          ENUM('Active','Graduated','Suspended','Withdrawn')
                    NOT NULL DEFAULT 'Active',
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_students_email UNIQUE (email)
);

-- 2. TEACHERS
CREATE TABLE teachers (
    teacher_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL,
    phone           VARCHAR(20)  NULL,
    specialization  VARCHAR(100) NULL,
    hire_date       DATE         NOT NULL,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_teachers_email UNIQUE (email)
);

-- 3. COURSES
CREATE TABLE courses (
    course_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_code   VARCHAR(10)  NOT NULL,
    course_name   VARCHAR(100) NOT NULL,
    description   TEXT         NULL,
    credit_hours  TINYINT UNSIGNED NOT NULL DEFAULT 3,
    CONSTRAINT uq_courses_code UNIQUE (course_code),
    CONSTRAINT chk_credit_hours CHECK (credit_hours BETWEEN 1 AND 6)
);

-- 4. CLASSES (a course offering taught by one teacher)
CREATE TABLE classes (
    class_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_id      INT UNSIGNED NOT NULL,
    teacher_id     INT UNSIGNED NOT NULL,
    section        VARCHAR(5)   NOT NULL DEFAULT 'A',
    academic_year  YEAR         NOT NULL,
    semester       ENUM('Spring','Summer','Fall') NOT NULL,
    room           VARCHAR(20)  NULL,
    schedule_day   ENUM('Mon','Tue','Wed','Thu','Fri','Sat') NULL,
    start_time     TIME         NULL,
    end_time       TIME         NULL,
    max_capacity   SMALLINT UNSIGNED NOT NULL DEFAULT 30,
    CONSTRAINT fk_classes_course  FOREIGN KEY (course_id)
        REFERENCES courses(course_id)   ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_classes_teacher FOREIGN KEY (teacher_id)
        REFERENCES teachers(teacher_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_class_offering UNIQUE (course_id, section, academic_year, semester),
    CONSTRAINT chk_class_time CHECK (end_time IS NULL OR end_time > start_time)
);

-- 5. ENROLLMENTS (junction table: students <-> classes)
CREATE TABLE enrollments (
    enrollment_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id       INT UNSIGNED NOT NULL,
    class_id         INT UNSIGNED NOT NULL,
   enrollment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status           ENUM('Enrolled','Dropped','Completed') NOT NULL DEFAULT 'Enrolled',
    final_grade      CHAR(2) NULL,
    CONSTRAINT fk_enr_student FOREIGN KEY (student_id)
        REFERENCES students(student_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_enr_class FOREIGN KEY (class_id)
        REFERENCES classes(class_id)    ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_student_class UNIQUE (student_id, class_id)
);

-- 6. STUDENT_ATTENDANCE
CREATE TABLE student_attendance (
    attendance_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    enrollment_id    INT UNSIGNED NOT NULL,
    attendance_date  DATE NOT NULL,
    status           ENUM('Present','Absent','Late','Excused') NOT NULL DEFAULT 'Present',
    remarks          VARCHAR(255) NULL,
    CONSTRAINT fk_att_enrollment FOREIGN KEY (enrollment_id)
        REFERENCES enrollments(enrollment_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_att_per_day UNIQUE (enrollment_id, attendance_date)
);

-- 2. INDEXES 
CREATE INDEX idx_students_name   ON students (last_name, first_name);
CREATE INDEX idx_students_status ON students (status);
CREATE INDEX idx_teachers_name   ON teachers (last_name, first_name);
CREATE INDEX idx_classes_teacher ON classes (teacher_id);
CREATE INDEX idx_classes_term    ON classes (academic_year, semester);
CREATE INDEX idx_enr_class       ON enrollments (class_id);
CREATE INDEX idx_att_date        ON student_attendance (attendance_date);

-- 3. SAMPLE DATA (same order as the tables)
INSERT INTO students (first_name, last_name, email, phone, date_of_birth, gender, address) VALUES
('Ayesha', 'Khan',   'ayesha.khan@school.edu',  '0300-1111111', '2008-03-14', 'Female', 'F-7, Islamabad'),
('Ahmed',  'Raza',   'ahmed.raza@school.edu',   '0301-2222222', '2007-11-02', 'Male',   'G-9, Islamabad'),
('Fatima', 'Noor',   'fatima.noor@school.edu',  NULL,           '2008-07-21', 'Female', NULL),
('Usman',  'Tariq',  'usman.tariq@school.edu',  '0302-3333333', '2007-05-30', 'Male',   'I-8, Islamabad'),
('Sara',   'Malik',  'sara.malik@school.edu',   '0303-4444444', '2008-01-09', 'Female', 'E-11, Islamabad');

INSERT INTO teachers (first_name, last_name, email, phone, specialization, hire_date) VALUES
('Imran',  'Ali',     'imran.ali@school.edu',     '0311-5555555', 'Mathematics', '2018-08-01'),
('Sana',   'Hussain', 'sana.hussain@school.edu',  '0312-6666666', 'Physics',     '2020-01-15'),
('Bilal',  'Ahmed',   'bilal.ahmed@school.edu',   NULL,           'English',     '2019-03-10');

INSERT INTO courses (course_code, course_name, description, credit_hours) VALUES
('MATH101', 'Mathematics I', 'Algebra and basic calculus', 4),
('PHY101',  'Physics I',     'Mechanics and motion',       3),
('ENG101',  'English I',     NULL,                         2);

INSERT INTO classes (course_id, teacher_id, section, academic_year, semester, room, schedule_day, start_time, end_time, max_capacity) VALUES
(1, 1, 'A', 2026, 'Fall', 'R-101', 'Mon', '09:00', '10:30', 30),
(2, 2, 'A', 2026, 'Fall', 'Lab-1', 'Tue', '11:00', '12:30', 25),
(3, 3, 'A', 2026, 'Fall', 'R-102', 'Wed', '09:00', '10:00', 30),
(1, 1, 'B', 2026, 'Fall', 'R-103', 'Thu', '09:00', '10:30', 30);

INSERT INTO enrollments (student_id, class_id, enrollment_date, status) VALUES
(1, 1, '2026-09-01', 'Enrolled'),
(1, 2, '2026-09-01', 'Enrolled'),
(2, 1, '2026-09-01', 'Enrolled'),
(2, 3, '2026-09-02', 'Enrolled'),
(3, 2, '2026-09-02', 'Enrolled'),
(4, 4, '2026-09-03', 'Enrolled'),
(5, 3, '2026-09-03', 'Dropped');

INSERT INTO student_attendance (enrollment_id, attendance_date, status, remarks) VALUES
(1, '2026-09-07', 'Present', NULL),
(1, '2026-09-14', 'Late',    'Bus delay'),
(2, '2026-09-08', 'Present', NULL),
(3, '2026-09-07', 'Absent',  'Sick'),
(3, '2026-09-14', 'Excused', 'Medical leave'),
(4, '2026-09-09', 'Present', NULL),
(5, '2026-09-08', 'Present', NULL),
(6, '2026-09-10', 'Present', NULL);

-- 4. VERIFICATION QUERIES (run one at a time for screenshots)

-- SHOW TABLES;
-- SHOW CREATE TABLE classes;
-- SHOW INDEX FROM enrollments;
-- SELECT * FROM students;
-- SELECT * FROM teachers;
-- SELECT * FROM courses;
-- SELECT * FROM classes;
-- SELECT * FROM enrollments;
-- SELECT * FROM student_attendance;

-- Many-to-many join (should return 7 rows)
-- SELECT s.first_name, s.last_name, c.course_name, t.last_name AS teacher
-- FROM enrollments e
-- JOIN students s  ON s.student_id = e.student_id
-- JOIN classes  cl ON cl.class_id  = e.class_id
-- JOIN courses  c  ON c.course_id  = cl.course_id
-- JOIN teachers t  ON t.teacher_id = cl.teacher_id;

-- Row counts (expect 5, 3, 3, 4, 7, 8)
-- SELECT 'students' AS tbl, COUNT(*) AS rows_count FROM students
-- UNION ALL SELECT 'teachers', COUNT(*) FROM teachers
-- UNION ALL SELECT 'courses', COUNT(*) FROM courses
-- UNION ALL SELECT 'classes', COUNT(*) FROM classes
-- UNION ALL SELECT 'enrollments', COUNT(*) FROM enrollments
-- UNION ALL SELECT 'student_attendance', COUNT(*) FROM student_attendance;

-- 5. CONSTRAINT TESTS (each should FAIL with an error)

-- Test 1: duplicate email (UNIQUE) -> Error 1062
-- INSERT INTO students (first_name, last_name, email, date_of_birth)
-- VALUES ('Test','User','ayesha.khan@school.edu','2008-01-01');

-- Test 2: double enrollment (composite UNIQUE) -> Error 1062
-- INSERT INTO enrollments (student_id, class_id) VALUES (1, 1);

-- Test 3: non-existent student (FOREIGN KEY) -> Error 1452
-- INSERT INTO enrollments (student_id, class_id) VALUES (999, 1);

-- Test 4: delete teacher who has classes (RESTRICT) -> Error 1451
-- DELETE FROM teachers WHERE teacher_id = 1;

-- Test 5: invalid credit hours (CHECK) -> Error 3819
-- INSERT INTO courses (course_code, course_name, credit_hours)
-- VALUES ('BAD1','Bad Course', 10);

-- Test 6: cascade delete, undone with ROLLBACK
-- START TRANSACTION;
-- DELETE FROM enrollments WHERE enrollment_id = 3;
-- SELECT * FROM student_attendance;   -- 6 rows (cascade removed 2)
-- ROLLBACK;
-- SELECT * FROM student_attendance;   -- 8 rows again


-- 6. BONUS: attendance percentage per student per class

-- SELECT s.first_name, s.last_name, c.course_name,
--        COUNT(*) AS total_days,
--        SUM(a.status IN ('Present','Late')) AS attended,
--        ROUND(100 * SUM(a.status IN ('Present','Late')) / COUNT(*), 1) AS attendance_pct
-- FROM student_attendance a

-- JOIN enrollments e ON e.enrollment_id = a.enrollment_id
-- JOIN students s    ON s.student_id    = e.student_id
-- JOIN classes cl    ON cl.class_id     = e.class_id
-- JOIN courses c     ON c.course_id     = cl.course_id
-- GROUP BY s.student_id, c.course_id;


SHOW TABLES;
DESCRIBE students;
DESCRIBE teachers;
DESCRIBE courses;
DESCRIBE enrollments;
SELECT @@port, @@hostname, DATABASE();