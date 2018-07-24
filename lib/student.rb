require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade, :id
  #attr_reader :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |array|
      self.new_from_db(array)
    end.first

  end

  def self.new_from_db(array)
    student = Student.new(@id,@name,@grade)
    student.id = array[0]
    student.name = array[1]
    student.grade = array[2]
    student
  end

  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ?
    WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)

  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT
        last_insert_rowid() FROM students")[0][0]
      end
    end
end
