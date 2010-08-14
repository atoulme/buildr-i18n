# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.  The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

Gem::Specification.new do |spec|
  spec.name           = 'buildri18n'
  spec.version        = '0.0.1'
  spec.author         = 'Buildr i18n'
  spec.email          = "users@buildr.apache.org"
  spec.homepage       = "http://www.github.com/atoulme/buildri18n"
  spec.summary        = "Buildr i18n plugin"
  spec.description    = <<-TEXT
A complementary system to create translation of strings placed in properties files.
  TEXT

  # Rakefile needs to create spec for both platforms (ruby and java), using the
  # $platform global variable.  In all other cases, we figure it out from RUBY_PLATFORM.
  spec.platform       = $platform || RUBY_PLATFORM[/java/] || 'ruby'

  # Tested against these dependencies.
  spec.add_dependency 'buildr',               '>= 1.4.0'
  spec.add_dependency 'jekyll',               '~> 0.6.2'
end
