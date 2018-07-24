require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
      DB[:conn].execute("DROP TABLE students;")
  end

  def persisted?
    !!id
  end

  def save
    if persisted?
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?);
        SQL
      DB[:conn].execute(sql, self.name, self.grade)
      saved_student_data = DB[:conn].execute("SELECT * FROM students WHERE id = last_insert_rowid()")
      self.id = saved_student_data[0][0]
    end
    self
  end

    def update
      DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?;", self.name, self.grade, self.id)
    end

    def self.create(name, grade)
      student = Student.new(name, grade)
      student.save
      student
    end

    def self.new_from_db(row)
      new_student = Student.new(row[1], row[2])
      new_student.id = row[0]
      new_student
    end

    def self.find_by_name(name)
      DB[:conn].execute("SELECT * FROM students WHERE name = ?", name).map do |row|
        self.new_from_db(row)
      end.first
    end
end
