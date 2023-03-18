--  Copyright (C) 2023 Simon Wright <simon@pushface.org>
--  SPDX-License-Identifier: GPL-3.0-or-later

with Ada.Strings.Fixed;
with Ada.Text_IO;

package body Components is
   use Libadalang;
   use Ada.Text_IO;

   procedure Visit (Node  : Analysis.Ada_Node'Class;
                    Depth : Natural := 0);

   procedure Process_Compilation_Unit
     (Unit : Libadalang.Analysis.Analysis_Unit)
   is
   begin
      Visit (Unit.Root, Depth => 0);
   end Process_Compilation_Unit;

   procedure Visit (Node  : Analysis.Ada_Node'Class;
                    Depth : Natural := 0)
   is
      use Analysis;
      use Ada.Strings.Fixed;
   begin
      if Is_Null (Node) then
         return;
      end if;

      --  Node.Image is e.g. <SubpDecl ["H"] sample.ads:11:4-11:16>
      --
      --  The SubpDecl part is the node name (sort-of type), the rest
      --  is pretty irrelevant for us.
      --
      --  If the node has children, just output <name>\n<children/>\n</name>\n
      --
      --  If it's a leaf node and doesn't contain text, then just
      --  output <name/>\n (could perhaps just ignore it? no, consider
      --  SubpKindProcedure).
      --
      --  If it's a leaf node and does contain text, output
      --  <name>text</name)\n.
      Output_Node :
      declare
         Leading : constant String := [1 .. 2 * Depth => ' '];
         Image : constant String := Node.Image;
         Node_Type : constant String
           := Image (Image'First + 1 .. Index (Image, " ") - 1);
         Node_Text : constant String := Libadalang.Text.Image (Node.Text);
      begin
         if Node.Children_Count = 0 then
            if Node_Text'Length = 0 then
               Put_Line (Leading & "<" & Node_Type & "/>");
            else
               Put_Line (Leading
                           & "<" & Node_Type & ">"
                           & Node_Text
                           & "</" & Node_Type & ">");
            end if;
         else
            Put_Line (Leading & "<" & Node_Type & ">");
            for J in First_Child_Index (Node) .. Last_Child_Index (Node) loop
               Visit (Child (Node, J), Depth => Depth + 1);
            end loop;
            Put_Line (Leading & "</" & Node_Type & ">");
         end if;
      end Output_Node;
   end Visit;

end Components;
