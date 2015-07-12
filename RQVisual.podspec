Pod::Spec.new do |s|
  s.platform     = :ios, "8.0"
  s.name         = "RQVisual"
  s.version      = "1.0.0"
  s.summary      = "A tool for laying out views in code."

  s.description  = <<-DESC
                    Visual is a tool for laying out views in code using a visual
                    style formats similar to those used by NSLayoutConstraint.
                   DESC

  s.homepage      = "https://github.com/rqueue/RQVisual"
  s.license       = "MIT"
  s.author        = { "Ryan Quan" => "ryanhquan@gmail.com" }
  s.source        = { :git => "https://github.com/rqueue/RQVisual.git", :tag => "1.0.0" }
  s.source_files  = "RQVisual", "RQVisual/**/*.{h,m}"
  s.requires_arc  = true
end
