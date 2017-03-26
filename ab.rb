class Ab < Formula
  desc "Apache HTTP server benchmarking tool"
  homepage "https://httpd.apache.org/docs/trunk/programs/ab.html"
  url "https://archive.apache.org/dist/httpd/httpd-2.4.25.tar.bz2"
  sha256 "f87ec2df1c9fee3e6bfde3c8b855a3ddb7ca1ab20ca877bd0e2b6bf3f05c80b2"

  bottle do
    cellar :any
    sha256 "e1be1ce5f10ad03d343cb67db69897f3bcf9b9f10f522133657e6aeea0cdcb6f" => :sierra
    sha256 "75827f06aa601d6cc9df2d8caa0d1f7140a5b71902c187cff2ac9bc7ca14ed51" => :el_capitan
    sha256 "492815aecc46e1a02557e794d787e05076814182d6e37c845944e8c3022c943a" => :yosemite
  end

  keg_only :provided_by_osx

  depends_on "apr-util"
  depends_on "libtool" => :build

  conflicts_with "httpd22", "httpd24", :because => "both install `ab`"

  # Disable requirement for PCRE, because "ab" does not use it
  patch :DATA

  def install
    # Mountain Lion requires this to be set, as otherwise libtool complains
    # about being "unable to infer tagged configuration"
    ENV["LTFLAGS"] = "--tag CC"
    system "./configure", "--prefix=#{prefix}", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-apr=#{Formula["apr"].opt_prefix}",
                          "--with-apr-util=#{Formula["apr-util"].opt_prefix}"

    cd "support" do
      system "make", "ab"
      bin.install "ab"
    end
    man1.install "docs/man/ab.1"
  end

  test do
    system "#{bin}/ab", "-k", "-n", "10", "-c", "10", "http://www.apple.com/"
  end
end

__END__
diff --git a/configure b/configure
index 90ae8be..243e9cf 100755
--- a/configure
+++ b/configure
@@ -6156,8 +6156,6 @@ $as_echo "$as_me: Using external PCRE library from $PCRE_CONFIG" >&6;}
     done
   fi
 
-else
-  as_fn_error $? "pcre-config for libpcre not found. PCRE is required and available from http://pcre.org/" "$LINENO" 5
 fi
 
   APACHE_VAR_SUBST="$APACHE_VAR_SUBST PCRE_LIBS"
