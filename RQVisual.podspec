Pod::Spec.new do |s|
  s.name         = "RQVisual"
  s.version      = "0.0.1"
  s.summary      = "A tool for laying out views in code."

  s.description  = <<-DESC
                    Visual is a tool for laying out views in code using a visual
                    style formats similar to those used by NSLayoutConstraint.
                   DESC

  s.homepage      = "https://github.com/rqueue/RQVisual"
  s.license       = "MIT"
  s.author        = { "Ryan Quan" => "ryanhquan@gmail.com" }
  s.source        = { :git => "git@github.com:rqueue/RQVisual.git", :tag => "0.0.1" }
  s.source_files  = "RQVisual", "RQVisual/**/*.{h,m}"
end
