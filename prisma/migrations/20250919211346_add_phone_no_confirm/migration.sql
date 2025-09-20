/*
  Warnings:

  - You are about to drop the column `confirmPassword` on the `User` table. All the data in the column will be lost.
  - Made the column `password` on table `User` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "public"."User" DROP COLUMN "confirmPassword",
ALTER COLUMN "password" SET NOT NULL;
