-- Create custom types
CREATE TYPE user_role AS ENUM ('admin', 'qc', 'editor');
CREATE TYPE file_status AS ENUM ('assigned', 'pending', 'approved', 'rejected');

-- Create users table
CREATE TABLE users (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  role user_role DEFAULT 'editor',
  salary NUMERIC DEFAULT 200000,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create subtitle_files table
CREATE TABLE subtitle_files (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  file_name TEXT NOT NULL,
  assigned_editor UUID REFERENCES users(id),
  total_errors INTEGER DEFAULT 0,
  missed_errors INTEGER DEFAULT 0,
  corrected_lines INTEGER DEFAULT 0,
  status file_status DEFAULT 'assigned',
  submission_date TIMESTAMPTZ,
  qc_notes TEXT,
  deduction_amount NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create qc_logs table
CREATE TABLE qc_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  subtitle_file_id UUID REFERENCES subtitle_files(id),
  qc_user UUID REFERENCES users(id),
  line_number INTEGER NOT NULL,
  error_type TEXT NOT NULL,
  correction_note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create attendance table
CREATE TABLE attendance (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  date DATE DEFAULT CURRENT_DATE,
  files_completed INTEGER DEFAULT 0,
  attendance_points NUMERIC DEFAULT 0,
  bonus_points NUMERIC DEFAULT 0,
  UNIQUE(user_id, date)
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE subtitle_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Admins can view all profiles" ON users FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
