require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade, :id
  # attr_reader :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
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

  def save
    if self.id
      self.update #if id already created, will just need to be updated in the db
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.grade)
        @id = DB[:conn].execute("SELECT   last_insert_rowid() FROM students")[0][0]
    end
  end

#select by id, update name or grade
  def update
    sql = <<-SQL
      UPDATE students SET name=?, grade=? WHERE  id=?;
        )
        SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.new_from_db(array)
    new_student = Student.new(@id, @name, @grade)
    new_student.id = array[0]
    new_student.name = array[1]
    new_student.grade = array[2]
    new_student
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


end
