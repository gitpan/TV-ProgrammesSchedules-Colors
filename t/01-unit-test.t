#!perl

use strict; use warnings;
use TV::ProgrammesSchedules::Colors;
use Test::More tests => 5;

my ($tv);

eval { $tv = TV::ProgrammesSchedules::Colors->new(['in']); };
like($@, qr/Single parameters to new\(\) must be a HASH ref/);

eval { $tv = TV::ProgrammesSchedules::Colors->new({location => 'ina'}); };
like($@, qr/Attribute \(location\) does not pass the type constraint/);

eval { $tv = TV::ProgrammesSchedules::Colors->new({yyyy=>0, mm=>1, dd=>1}); };
like($@, qr/Attribute \(yyyy\) does not pass the type constraint/);

eval { $tv = TV::ProgrammesSchedules::Colors->new({yyyy=>2011, mm=>13, dd=>1}); };
like($@, qr/Attribute \(mm\) does not pass the type constraint/);

eval { $tv = TV::ProgrammesSchedules::Colors->new({yyyy=>2011, mm=>1, dd=>32}); };
like($@, qr/Attribute \(dd\) does not pass the type constraint/);