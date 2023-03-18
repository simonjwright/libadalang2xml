--  Copyright (C) 2023 Simon Wright <simon@pushface.org>
--  SPDX-License-Identifier: GPL-3.0-or-later

with Ada.Command_Line;
with Ada.Text_IO;
with Libadalang.Analysis;
with Components;

procedure Libadalang2xml is
   use Ada.Text_IO;
   use Libadalang;

   Context : constant Analysis.Analysis_Context := Analysis.Create_Context;

begin

   Files :
   for J in 1 .. Ada.Command_Line.Argument_Count loop

      Each_File :
      declare
         Filename : constant String := Ada.Command_Line.Argument (J);
         Unit     : constant Analysis.Analysis_Unit :=
           Context.Get_From_File (Filename);
      begin
         Put_Line (Standard_Error, "processing " & Filename);

         if Unit.Has_Diagnostics then
            for D of Unit.Diagnostics loop
               Put_Line (Unit.Format_GNU_Diagnostic (D));
            end loop;
            Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
            return;
         else
            Components.Process_Compilation_Unit (Unit);
         end if;

         New_Line;
      end Each_File;

   end loop Files;

end Libadalang2xml;
